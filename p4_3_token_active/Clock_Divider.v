/*****************************************************************************************/
/********************   Author    :     Eslam Hussein                 ********************/
/********************   Module    :     Clock Divider                 ********************/
/********************   Date      :     31 Aug 2021                   ********************/
/********************   Version   :     02                            ********************/
/*****************************************************************************************/

/********************************    Module Definition    ********************************/ 
module Clock_Divider 
/********************************    Module Parameters    ********************************/ 
    #( 
         parameter Div_Ratio_Width = 3 
     )
/********************************     Module Interface    ********************************/ 
     (
	     input wire i_ref_clk ,
		 input wire i_rst_n ,
		 input wire i_clk_en ,
		 input wire [Div_Ratio_Width-1:0] i_div_ratio ,
		 output reg o_div_clk 	 	
	 );
	 
/********************************   Signal Declaration   *********************************/
reg [(Div_Ratio_Width-2):0] count ;
reg Out_Clock = 'b0 ;
/********************************        Module Body     *********************************/ 
/* Clock Divider Algorithm */
always @(posedge i_ref_clk or posedge i_rst_n)
     begin
	     if ( i_rst_n )
		     begin
			     count <= {(Div_Ratio_Width-1){1'b0}} ;			 			 
			     o_div_clk <= 1'b0 ; 
			 end
	     else if (i_clk_en)
	         begin
			     count <= count + 'b1 ;			 			 								 
			     if (i_div_ratio[0] == 1'b0)   /* even */
			         begin
					     if (count == ((i_div_ratio>>1)-1))
                             begin
							 	 o_div_clk <= ~o_div_clk ;	
                                 count <= {(Div_Ratio_Width-1){1'b0}} ;			 			 							 
							 end
					     else 
						     begin
							     o_div_clk <= o_div_clk ;							 
							 end					 					
					 end
                 else                         /* Odd */
				     begin
					     if (((count == ((i_div_ratio>>1)))&&(Out_Clock == 'b0))||((count == ((i_div_ratio>>1)-1))&&(Out_Clock == 'b1)))
                             begin
							 	 o_div_clk <= ~o_div_clk ;	
								 Out_Clock <= ~ Out_Clock ;
                                 count <= {(Div_Ratio_Width-1){1'b0}} ;			 			 							 
							 end
					     else 
						     begin
							     o_div_clk <= o_div_clk ;							 
							 end					 
					 end					 
			 end
		 else 
		     begin
	             count <= {(Div_Ratio_Width-1){1'b0}} ;			 			 			 
			     o_div_clk <= 1'b0 ; 				 
			 end		 
	 end	 
/********************************        Module End      *********************************/ 
endmodule
