module LCD_TEST(iclk, irst, LCD_DATA, LCD_RW, LCD_EN, LCD_RS);

input						iclk;
input						irst;
output	logic	[7:0]	LCD_DATA;
output					  LCD_RW;
output	logic			  LCD_EN;
output	logic			  LCD_RS;

//внутренние регистры
logic	[5:0]	LUT_INDEX;	//индекс передаваемого значения
logic	[8:0]	LUT_DATA;	//передаваемое значение
logic	[2:0]	mLCD_ST;	//этапы передачи команды
logic	[17:0]	mDLY;		//регистр счётчика задержки

localparam	LCD_INIT	=	0;					//LUT_INDEX == 0
localparam	LCD_LINE1	=	5;					//начало первой линии: LUT_INDEX == 5
localparam	LCD_CH_LINE	=	LCD_LINE1 + 16;		//индекс смены строк: LUT_INDEX == 5 + 16 = 21
localparam	LCD_LINE2	=	LCD_LINE1 + 16 + 1;	//начало второй линии: LUT_INDEX == 5 + 16 + 1 = 21
localparam	LCD_SIZE	=	LCD_LINE1 + 32 + 1;	//размер таблицы соответствия: LUT_INDEX == 5 + 16*2 + 1 = 38

assign LCD_RW = 1'b0; //запись

always_ff @(posedge iclk or negedge irst) begin
	if (!irst) begin
		LUT_INDEX	<=	0;
		mLCD_ST		<=	0;
		mDLY		<=	0;
		LCD_RS		<=	0;
	end
	else begin
		if (LUT_INDEX < LCD_SIZE) begin
			case (mLCD_ST)
				0 : begin
					LCD_DATA	<=	LUT_DATA[7:0];
					LCD_RS		<=	LUT_DATA[8];
					mLCD_ST		<=	1;
				end
				1 : begin
					LCD_EN		<=	1'b1;
					mLCD_ST		<=	2;
				end
				2 : begin
					if(mDLY < 18'h17) //задержка на 460 нс
						mDLY	<=	mDLY + 1'b1;
					else begin
						LCD_EN	<=	1'b0;
						mDLY	<=	0;
						mLCD_ST	<=	3;
					end
				end
				3 : begin
					if(mDLY < 18'h14200) //задержка на 1,64 мс
						mDLY	<=	mDLY + 1'b1;
					else begin
						mDLY	<=	0;
						mLCD_ST	<=	4;
					end
				end
				4 : begin
					LUT_INDEX	<=	LUT_INDEX + 1'b1;
					mLCD_ST	<=	0;
				end
			endcase
		end
	end
end

always_comb begin
	case (LUT_INDEX)
		//инициализация
		LUT_INIT + 0   : LUT_DATA = 9'h038;	//DL = 0x8D, N = 2R, F = 5*7 Style
		LUT_INIT + 1   : LUT_DATA = 9'h00C;	//включаем дисплей
		LUT_INIT + 2   : LUT_DATA = 9'h001;	//очищаем дисплей
		LUT_INIT + 3   : LUT_DATA = 9'h006;	//пишем слева направо
		LUT_INIT + 4   : LUT_DATA = 9'h080;	//устанавливаем адрес первого знака
		//линия 1
		LUT_LINE1 + 0  : LUT_DATA = 9'h1E0;
		LUT_LINE1 + 1  : LUT_DATA = 9'h1B8;
		LUT_LINE1 + 2  : LUT_DATA = 9'h163;
		LUT_LINE1 + 3  : LUT_DATA = 9'h1BE;
		LUT_LINE1 + 4  : LUT_DATA = 9'h1BB;
		LUT_LINE1 + 5  : LUT_DATA = 9'h165;
		LUT_LINE1 + 6  : LUT_DATA = 9'h1A6;
		LUT_LINE1 + 7  : LUT_DATA = 9'h120;
		LUT_LINE1 + 8  : LUT_DATA = 9'h14C;
		LUT_LINE1 + 9  : LUT_DATA = 9'h143;
		LUT_LINE1 + 10 : LUT_DATA = 9'h144;
		LUT_LINE1 + 11 : LUT_DATA = 9'h131;
		LUT_LINE1 + 12 : LUT_DATA = 9'h136;
		LUT_LINE1 + 13 : LUT_DATA = 9'h130;
		LUT_LINE1 + 14 : LUT_DATA = 9'h132;
		LUT_LINE1 + 15 : LUT_DATA = 9'h120;
		//смена линии
		LCD_CH_LINE    : LUT_DATA = 9'h0C0;
		//линия 2
		LUT_LINE2 + 0  : LUT_DATA = 9'h138;
		LUT_LINE2 + 1  : LUT_DATA = 9'h120;
		LUT_LINE2 + 3  : LUT_DATA = 9'h162;
		LUT_LINE2 + 4  : LUT_DATA = 9'h169;
		LUT_LINE2 + 5  : LUT_DATA = 9'h174;
		LUT_LINE2 + 6  : LUT_DATA = 9'h120;
		LUT_LINE2 + 7  : LUT_DATA = 9'h170;
		LUT_LINE2 + 8  : LUT_DATA = 9'h161;
		LUT_LINE2 + 9  : LUT_DATA = 9'h172;
		LUT_LINE2 + 10 : LUT_DATA = 9'h161;
		LUT_LINE2 + 11 : LUT_DATA = 9'h16C;
		LUT_LINE2 + 12 : LUT_DATA = 9'h16C;
		LUT_LINE2 + 13 : LUT_DATA = 9'h165;
		LUT_LINE2 + 14 : LUT_DATA = 9'h16C;
		LUT_LINE2 + 15 : LUT_DATA = 9'h120;
		//по умолчанию
		default        : LUT_DATA = 9'h000;
	endcase
end

endmodule