module hazardResolve(wb_RegWrite,
					wb_DMemWrite,
					wb_DMemEn,
					wb_WriteReg, 
					mem_RegWrite,
					mem_DMemWrite,
					mem_DMemEn,
					mem_WriteReg, 
					exe_ReadReg1, 
					exe_ReadReg2,
					dec_ReadReg1, 
					Reg1_EX-EXFwrd,
					Reg1_MEM-EXFwrd,
					Reg1_EX-DFwrd,
					Reg1_MEM-DFwrd.
					Reg2_EX-EXFwrd,
					Reg2_MEM-EXFwrd
					);
					
	input[2:0] wb_WriteReg, mem_WriteReg, exe_ReadReg1, 
			   exe_ReadReg2, dec_ReadReg1;
			   
	input wb_RegWrite,
		  wb_DMemWrite,
	   	  wb_DMemEn,
		  mem_RegWrite,
		  mem_DMemWrite,
		  mem_DMemEn;
		  
	output Reg1_EX-EXFwrd,
		   Reg1_MEM-EXFwrd,
	       Reg1_EX-DFwrd,
		   Reg1_MEM-DFwrd.
		   Reg2_EX-EXFwrd,
		   Reg2_MEM-EXFwrd;
		   
	wire wb_DMemRead,
		 mem_DMemRead;
		 
	assign wb_DMemRead = wb_DMemEn & ~wb_DMemWrite;
	assign mem_DMemRead = mem_DMemEn & ~mem_DMemWrite;
	
	assign Reg1_EX-EXFwrd = mem_RegWrite?
									    (~mem_DMemRead)?
													   (mem_WriteReg==exe_ReadReg1)?1'b1:1'b0
													   :1'b0
									    :1'b0;
										
	assign Reg2_EX-EXFwrd = mem_RegWrite?
									    (~mem_DMemRead)?
													   (mem_WriteReg==exe_ReadReg2)?1'b1:1'b0
													   :1'b0
									    :1'b0;
										
	assign Reg1_MEM-EXFwrd = wb_RegWrite?
									    (wb_WriteReg==exe_ReadReg1)?1'b1:1'b0
						 			    :1'b0;
				
	assign Reg2_MEM-EXFwrd = wb_RegWrite?
									    (wb_WriteReg==exe_ReadReg2)?1'b1:1'b0
						 			    :1'b0;
										
	assign Reg1_EX-DFwrd = mem_RegWrite?
									    (~mem_DMemRead)?
													   (mem_WriteReg==dec_ReadReg1)?1'b1:1'b0
													   :1'b0
									    :1'b0;
										
	assign Reg1_MEM-DFwrd = wb_RegWrite?
									    (wb_WriteReg==dec_ReadReg1)?1'b1:1'b0
						 			    :1'b0;
										
endmodule