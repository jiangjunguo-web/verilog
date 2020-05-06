//*****************************************************
//                  usart 发送模块
//*****************************************************
module usart_tx(
	input sys_clk,
	input sys_rst_n,
	
	input [7:0] data_in,
	input data_en,
	output reg data_out
);

//parameter define 
parameter BOUNDS  =  115200;
parameter S_CLK   =  50_000_000;
localparam S_CNT  =  S_CLK / BOUNDS;


//reg define 
reg data_en_1;
reg data_en_2;
reg [ 7:0] data_reg;
reg [ 3:0] data_cnt;
reg [15:0] cnt;
reg tx_valid;

//wire define 
wire tx_flag;        //发送开始标记

//****************************************************
//                     main code 
//****************************************************
//捕捉开始发送的上升沿
assign tx_flag = data_en_1 & (~data_en_2);

//打拍
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) 
	    {data_en_1, data_en_2} <= 2'b00;
	else 
	    {data_en_1, data_en_2} <= {data_en, data_en_1};
end 

//计数逻辑:位数、时钟
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
	    cnt <= 16'd0;
		 data_cnt <= 4'd0;
	end
	else if(tx_valid) begin
	    if(cnt < S_CNT - 1) begin
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

//发送时期电平 、数据寄存器
always @(posedge sys_clk or negedge sys_rst_n) begin
	 if(!sys_rst_n) begin
		  tx_valid <= 1'b0;
		  data_reg <= 8'd0;
	 end 
	 else if(tx_flag) begin
	     data_reg <= data_in;
		  tx_valid <= 1'b1;
	 end 
	 else if((data_cnt == 4'd9) && (cnt == (S_CNT >> 1))) begin
	     tx_valid <= 1'b0;
		  data_reg <= 8'd0;
	 end 	  
	 else begin
	 	  tx_valid <= tx_valid;
		  data_reg <= data_reg;
	 end	 
end 

//数据发送 
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) 
	    data_out <= 1'b1;
	else if(tx_valid) begin
		 case(data_cnt) 
		     4'd0 : data_out <= 1'b0;
			  4'd1 : data_out <= data_reg[0];
			  4'd2 : data_out <= data_reg[1];
			  4'd3 : data_out <= data_reg[2];
			  4'd4 : data_out <= data_reg[3];
			  4'd5 : data_out <= data_reg[4];
			  4'd6 : data_out <= data_reg[5];
			  4'd7 : data_out <= data_reg[6];
			  4'd8 : data_out <= data_reg[7];
			  4'd9 : data_out <= 1'b1;
			  default : ;
		 endcase
	end 
	else 
	    data_out <= 1'b1;
end 

endmodule 