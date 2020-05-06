//*******************************************************
//                       串口顶层模块
//*******************************************************
module usart(
	input sys_clk,             //时钟信号
	input sys_rst_n,           //系统复位信号
	
	input data_rx,            //输入的数据
	output data_tx
);

//parameter define 
parameter  BOUNDS  =  115200;
parameter  S_CLK   =  50_000_000;


//wire define 
wire [7:0] data;
wire data_en;

//*******************************************************
//                      main code
//*******************************************************

usart_rx #(.BOUNDS   (BOUNDS),
			  .S_CLK    (S_CLK))
u_usart_rx (
	.sys_clk        (sys_clk),
	.sys_rst_n      (sys_rst_n),
	
	.data_in        (data_rx),
	.data_out       (data),
	.data_en        (data_en)
);


usart_tx #(.BOUNDS   (BOUNDS),
			  .S_CLK    (S_CLK))
u_usart_tx (
	.sys_clk        (sys_clk),
	.sys_rst_n      (sys_rst_n),
	
	.data_in        (data),
	.data_out       (data_tx),
	.data_en        (data_en)
);


endmodule 