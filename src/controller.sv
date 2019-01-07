module controller #(
/* Параметр А зависит от частоты тактового генератора
 40 МГц -> А = 1000000
 50 МГц -> А = 1250000 */
	parameter int A = 1250000
 ) (
	input             clk,// тактовый генератор
	output            a_sd,//шаговый двигатель 1.1
	output            b_sd,//шаговый двигатель 2.1
	output    	 		c_sd,//шаговый двигатель 1.2
	output            d_sd,//шаговый двигатель 2.2
	input        	   snsr, // сигнал датчика
	input             in_toggle_strt, // начать моделирование
	input             back, // откат назад
	input             nul, // обнуление значения на индикаторах
	output   [7:0]  	digit, // индикаторы
	output   [7:0]		ind1,
	output   [7:0]		ind2,
	output   [7:0]		ind3,
	output   [7:0]		ind4,
	output   [7:0]		ind5,
	output   [7:0]		ind6,
	output   [7:0]		ind7,
	output   [7:0]		ind8
	);
/*
вывод на семисегментный индикатор необходимых значений
*/

reg [2:0]c = 1'b0;
reg [2:0]dynamic_temp = 1'b0;
reg  [7:0]  i_2;
reg  [7:0]  i_3;
reg  [7:0]  i_4;
reg  [7:0]  i_5;
reg  [7:0]  i_6;
 
always @ (posedge clk) begin
 
  c <= c + 1'b1;           //задание частоты переключения между индикаторами   
  if(c == 0)                   //по входной тактовой частоте
  begin
    dynamic_temp <= dynamic_temp + 1'b1; //переключение между индикаторами
  end
  case(dynamic_temp)
    3'b000 :  
    begin
     ind1 =  8'b11000000;
     digit = 8'b11111110;
    end
	 3'b001 :  
    begin
     ind2 = i_2; 
     digit = 8'b11111101;
    end
    3'b010 :  
    begin
     ind3 = i_3; 
     digit = 8'b11111011;
    end
    3'b011 :  
    begin
     ind4 = i_4; 
     digit = 8'b11110111;
    end
    3'b100 :  
    begin
     ind5 = i_5; 
     digit = 8'b11101111;
    end
    3'b101 :  
    begin
     ind6 = i_6; 
     digit = 8'b11011111;
    end
    3'b110 :  
    begin
     ind7 = 8'b10110111; // знак =
     digit = 8'b10111111;
    end
    3'b111 :  
    begin
     ind8 = 8'b11000111; // буква L
     digit = 8'b01111111;
    end
  endcase

/* Данный подмодуль предназначен для того, чтобы выводить нужные цифры на индикаторе. 
После анализа всех состояний была выявлена закономерность в поведении чисел:
i_1 всегда равна нулю;
i_2 принимает значения 0 и 5;
i_3 принимает значения 0,2,5,7;
Х4, Х5 принимает все доступные значения;
Х6 принимает значения от 0 до 8 (из параметров ползунка)*/
case (X)
	0:
	i_2 = 8'b11000000; //0
	1:
	i_2 = 8'b10010010; //5
endcase
case (X1)
	0:
	i_3 = 8'b11000000; //0
	1:
	i_3 = 8'b10010010; //2
	2:
	i_3 = 8'b10010010; //5
	3:
	i_3 = 8'b11111000; //7
endcase
case (X2)
	0:
	i_4 = 8'b11000000; //0
	1:
	i_4 = 8'b11111100; //1
	2:
	i_4 = 8'b10010010; //2
	3:
	i_4 = 8'b10110000; //3
	4:
	i_4 = 8'b10011000; //4
	5:
	i_4 = 8'b10010010; //5
	6:
	i_4 = 8'b10000010; //6
	7:
	i_4 = 8'b11111000; //7
	8:
	i_4 = 8'b10000000; //8
	9:
	i_4 = 8'b10010000; //9
endcase
case (X3)
	0:
	i_5 = 8'b11000000; //0
	1:
	i_5 = 8'b11111100; //1
	2:
	i_5 = 8'b10010010; //2
	3:
	i_5 = 8'b10110000; //3
	4:
	i_5 = 8'b10011000; //4
	5:
	i_5 = 8'b10010010; //5
	6:
	i_5 = 8'b10000010; //6
	7:
	i_5 = 8'b11111000; //7
	8:
	i_5 = 8'b10000000; //8
	9:
	i_5 = 8'b10010000; //9
endcase
case (X4)
	0:
	i_6 = 8'b11000000; //0
	1:
	i_6 = 8'b11111100; //1
	2:
	i_6 = 8'b10010010; //2
	3:
	i_6 = 8'b10110000; //3
	4:
	i_6 = 8'b10011000; //4
	5:
	i_6 = 8'b10010010; //5
	6:
	i_6 = 8'b10000010; //6
	7:
	i_6 = 8'b11111000; //7
	8:
	i_6 = 8'b10000000; //8
endcase
end
/* данный подмодуль генерирует сигналы для шагового двигателя и 
отправляет их к шаговому двигателю, а так же он является анализатором для индикаторов
           FULL                             
count_1 ____----____________--     
count_2 ________----__________     
count_3 ____________----______    
count_4 ________________----__      
*/	
reg [4:0]X = 0;
reg [4:0]X1 = 0;
reg [4:0]X2 = 0;
reg [4:0]X3 = 0;
reg [4:0]X4 = 0;
always @(posedge clk)
begin
if (count_1)
begin
	if (X == 2)
				begin
					X = 0;
					X1 = X1 + 1;
				end
				else
				begin
					X = X + 1;
				end
				if (X1 == 4)
				begin
					X1 = 0;
					X2 = X2+1;
				end
				if (X2 == 10)
				begin
					X2 = 0;
					X3 = X3 + 1;
				end
				if (X3 == 10)
				begin
				X3 = 0;
				X4 = X4 + 1;
				end
	end
else if (nul)
  begin
	X <= 0;
	X1 <= 0;
	X2 <= 0;
	X3 <= 0;
	X4 <= 0;
  end
	end
	always @(posedge clk)
	begin
	if (!back)
			begin
			if (count_1) 
				begin
						 a_sd <= 1;
	           		 b_sd <= 0;
	      			 c_sd <= 0;
	           		 d_sd <= 0;
				end
				if (count_2) 
				begin
							a_sd <= 0;
	            		b_sd <= 1;
							c_sd <= 0;
	            		d_sd <= 0;
				end
				if (count_3) 
				begin
						a_sd <= 0;
	            	b_sd <= 0;
	      			c_sd <= 1;
	           		d_sd <= 0;
				end
				if (count_4) 
				begin
						a_sd <= 0;
						b_sd <= 0;
	      			c_sd <= 0;
	            	d_sd <= 1;
				end
			end
	else
	begin
				begin
						a_sd <= 0;
	            	b_sd <= 0;
	      			c_sd <= 0;
	            	d_sd <= 1;
				end
				if (count_2) 
				begin
						a_sd <= 0;
	            	b_sd <= 0;
	      			c_sd <= 1;
	            	d_sd <= 0;
				end
				if (count_3) 
				begin
						a_sd <= 0;
	            	b_sd <= 1;
	      			c_sd <= 0;
	            	d_sd <= 0;
				end
				if (count_4) 
				begin
						a_sd <= 1;
	            	b_sd <= 0;
	      			c_sd <= 0;
	            	d_sd <= 0;
				end
		end
end 
/* Данный подмодуль предназначен для создания счетчика, под такт которого будет работа тактового двигателя
Работа заключается в следующем: есть параметер (А), в зависимости от счета cnt 
и равенства его параметру (1*A, 2*A, 3*A, 4*А) будет срабатывать определенный вывод count*/
	reg [0:26] cnt;	// x^26 = 67'108'864 > A = 50'000'000
	reg [0:2] count_1;
	reg [0:2] count_2;
	reg [0:2] count_3;
	reg [0:2] count_4;
always @(posedge clk)
begin
	if (in_toggle_strt)
	begin
		if (snsr)
		begin
			if (cnt == 4*A+1)
				begin
					cnt <= 0;
				end
			else
				begin
					if (cnt == 1*A)
					begin
						count_1 <= 1;
						count_2 <= 0;
						count_3 <= 0;
						count_4 <= 0;
					end
    				if (cnt == 2*A)
					begin
						count_1 <= 0;
						count_2 <= 1;
						count_3 <= 0;
						count_4 <= 0;
					end
					if (cnt == 3*A)
					begin
						count_1 <= 0;
						count_2 <= 0;
						count_3 <= 1;
						count_4 <= 0;
					end
					if (cnt == 4*A)
					begin
						count_1 <= 0;
						count_2 <= 0;
						count_3 <= 0;
						count_4 <= 1;
					end
					cnt = cnt + 1;
				end
			end
		end
		else if (!snsr)
			begin
				count_1 = 0;
				count_2 = 0;
			   count_3 = 0;
				count_4 = 0;
			end
	else if (!in_toggle_strt)
		begin
				count_1 = 0;
				count_2 = 0;
			   count_3 = 0;
				count_4 = 0;
		end
end
endmodule