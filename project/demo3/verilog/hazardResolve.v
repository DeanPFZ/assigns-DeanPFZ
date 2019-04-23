module hazardResolve(wb_RegWrite,
					wb_DMemWrite,
					wb_DMemEn,
					wb_WriteReg,
					mem_RegWrite,
					mem_DMemWrite,
					mem_DMemEn,
					mem_WriteReg,
					exe_DMemWrite,
					exe_DMemEn,
					exe_ReadReg1,
					exe_ReadReg2,
					exe_writeRegSel,
					exe_RegWrite,
					dec_ReadReg1,
					dec_ReadReg2,
          exe_OpCode,
					Reg1_EX_EXFwrd,
					Reg1_MEM_EXFwrd,
					Reg1_D_DFwrd,
					Reg1_EX_DFwrd,
					Reg1_MEM_DFwrd,
					Reg2_EX_EXFwrd,
					Reg2_MEM_EXFwrd,
					Reg2_D_DFwrd,
					Reg2_EX_DFwrd,
					Reg2_MEM_DFwrd,
					Reg1_EX_EXFwrd_Stall,
					Reg2_EX_EXFwrd_Stall,
					Reg1_EX_DFwrd_Stall,
					Reg2_EX_DFwrd_Stall
					);

	input[2:0] wb_WriteReg, mem_WriteReg, exe_ReadReg1,
			   exe_ReadReg2, exe_writeRegSel, dec_ReadReg1, dec_ReadReg2;
  input[4:0] exe_OpCode;

	input wb_RegWrite,
		  wb_DMemWrite,
	   	  wb_DMemEn,
		  mem_RegWrite,
		  mem_DMemWrite,
		  mem_DMemEn,
		  exe_DMemWrite,
		  exe_DMemEn,
		  exe_RegWrite;

	output Reg1_EX_EXFwrd,
		   Reg1_MEM_EXFwrd,
		   Reg1_D_DFwrd,
		   Reg1_EX_DFwrd,
		   Reg1_MEM_DFwrd,
		   Reg2_EX_EXFwrd,
		   Reg2_MEM_EXFwrd,
		   Reg2_D_DFwrd,
		   Reg2_EX_DFwrd,
		   Reg2_MEM_DFwrd,
		   Reg1_EX_EXFwrd_Stall,
		   Reg2_EX_EXFwrd_Stall,
		   Reg1_EX_DFwrd_Stall,
		   Reg2_EX_DFwrd_Stall;

	wire wb_DMemRead,
	     mem_DMemRead,
	     exe_DMemRead;

	assign wb_DMemRead = wb_DMemEn & ~wb_DMemWrite;
	assign mem_DMemRead = mem_DMemEn & ~mem_DMemWrite;
	assign exe_DMemRead = exe_DMemEn & ~exe_DMemWrite;

	assign Reg1_EX_EXFwrd = mem_RegWrite?
									    (~mem_DMemRead)?
													   (mem_WriteReg==exe_ReadReg1)?1'b1:1'b0
													   :1'b0
									    :1'b0;

	assign Reg2_EX_EXFwrd = mem_RegWrite?
									    (~mem_DMemRead)?
													   (mem_WriteReg==exe_ReadReg2)?1'b1:1'b0
													   :1'b0
									    :1'b0;
	assign Reg1_EX_DFwrd_Stall = exe_RegWrite?
									    (exe_DMemRead)?
													   (exe_writeRegSel==dec_ReadReg1)?1'b1:1'b0
													   :1'b0
									    :1'b0;
	assign Reg2_EX_DFwrd_Stall = exe_RegWrite?
									    (exe_DMemRead)?
													   (exe_writeRegSel==dec_ReadReg2)?1'b1:1'b0
													   :1'b0
									    :1'b0;
	assign Reg1_EX_EXFwrd_Stall = mem_RegWrite?
									    (mem_DMemRead)?
													   (mem_WriteReg==exe_ReadReg1)?1'b1:1'b0
													   :1'b0
									    :1'b0;
	assign Reg2_EX_EXFwrd_Stall = (exe_OpCode == 5'b10001)? 1'b0 : mem_RegWrite?
									    (mem_DMemRead)?
													   (mem_WriteReg==exe_ReadReg2)?1'b1:1'b0
													   :1'b0
									    :1'b0;

	assign Reg1_MEM_EXFwrd = wb_RegWrite?
									    (wb_WriteReg==exe_ReadReg1)?1'b1:1'b0
						 			    :1'b0;

	assign Reg2_MEM_EXFwrd = wb_RegWrite?
									    (wb_WriteReg==exe_ReadReg2)?1'b1:1'b0
						 			    :1'b0;

	assign Reg1_D_DFwrd = exe_RegWrite?
									    (~exe_DMemRead)?
													   (exe_writeRegSel==dec_ReadReg1)?1'b1:1'b0
													   :1'b0
									    :1'b0;

	assign Reg1_EX_DFwrd = mem_RegWrite?
									    (~mem_DMemRead)?
													   (mem_WriteReg==dec_ReadReg1)?1'b1:1'b0
													   :1'b0
									    :1'b0;
	assign Reg1_MEM_DFwrd = wb_RegWrite?
									    (wb_WriteReg==dec_ReadReg1)?1'b1:1'b0
						 			    :1'b0;

	assign Reg2_D_DFwrd = exe_RegWrite?
										(~exe_DMemRead)?
													   (exe_writeRegSel==dec_ReadReg2)?1'b1:1'b0
													   :1'b0
										:1'b0;

	assign Reg2_EX_DFwrd = mem_RegWrite?
									    (~mem_DMemRead)?
													   (mem_WriteReg==dec_ReadReg2)?1'b1:1'b0
													   :1'b0
									    :1'b0;
	assign Reg2_MEM_DFwrd = wb_RegWrite?
									    (wb_WriteReg==dec_ReadReg2)?1'b1:1'b0
						 			    :1'b0;

endmodule
