//****************************************************
//                  usart 接收模块
//****************************************************
module usart_rx(
	input sys_clk,
	input sys_rst_n,
	
	input data_in,
	output reg data_en,
	output reg [7:0] data_out
);

//parameter define 
parameter BOUNDS  = 115200;
parameter S_CLK   = 50_000_000;
localparam B_CNT  = S_CLK / BOUNDS;

//reg define 
reg data_in_d1;       
reg data_in_d2;
reg rx_valid;
reg [15:0] cnt;
reg [ 4:0] data_cnt;
reg [ 7:0] data_reg;

//wire define
wire rx_flag;

//****************************************************
//                   main code 
//****************************************************
assign rx_flag = (~data_in_d1) & data_in_d2;   //获取接收信号的下降沿

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
	    {data_in_d1, data_in_d2} <= 2'b00;
	end 
	else begin
	    {data_in_d1, data_in_d2} <= {data_in, data_in_d1};
	end
end 

//确定接收时间段
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) 
	    rx_valid <= 1'b0;
   else if(rx_flag)
	    rx_valid <= 1'b1;
	else if(data_cnt == 4'd9 && cnt == (B_CNT >> 1)) 
	    rx_valid <= 1'b0;
	else 
	    rx_valid <= rx_valid;
 end 

//接收时间计数
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
	    cnt <= 16'd0;
		 data_cnt <= 4'd0;
	end
   else if(rx_valid) begin
	    if(cnt < B_CNT - 1) begin
		     cnt <= cnt + 1'b1;
			  data_cnt <= data_cnt;
		 end
		 else begin
		     cnt <= 16'd0;
			  data_cnt <= data_cnt + 1'b1;
		 end
	end 
	else begin
	    cnt <= 16'd0;
		 data_cnt <= 4'd0;
   end 
end 

//数据接收
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
	    data_reg <= 8'd0;
	end 
	else if(rx_valid && cnt == (B_CNT >> 1)) begin
	    case(data_cnt)
			  4'd1 : data_reg[0] <= data_in_d2;
			  4'd2 : data_reg[1] <= data_in_d2;  
			  4'd3 : data_reg[2] <= data_in_d2;  
			  4'd4 : data_reg[3] <= data_in_d2;  
			  4'd5 : data_reg[4] <= data_in_d2;  
			  4'd6 : data_reg[5] <= data_in_d2;  
			  4'd7 : data_reg[6] <= data_in_d2;  
			  4'd8 : data_reg[7] <= data_in_d2; 
			  default : ; 
		 endcase 
	end 
end 

//数据发送
always @(posedge sys_clk or negedge sys_rst_n) begin
    if(!sys_rst_n) begin  
	     data_out <= 8'd0;
		  data_en  <= 1'd0;
	 end 
	 else if(data_cnt == 4'd9) begin
	     data_out <= data_reg;
		  data_en  <= 1'b1; 
	 end 
	 else begin
	     data_out <= 8'd0;
		  data_en <= 1'b0;
    end 	
end 
endmodule 
