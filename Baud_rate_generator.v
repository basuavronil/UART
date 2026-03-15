module baudrate_gen(input clk,
                    input rstn,
                    output reg [11:0]q,
                    output tick 
                  );
                  
       // wire [11:0]q_next;
        
        always@(posedge clk or negedge rstn)
        begin
        if (!rstn)
         q <= 1'b0;
        else 
         begin 
          if (q == 103)
           q <= 1'b0;
          else 
           q <= q +1;
         end
        end
           

        
        
       /* always@(posedge clk)
         begin
          if(!rstn)
           q <= 0;         
          else
           q <= q_next;
         end

    assign q_next = (q == 103) ? 0 : q+1;
     
     
endmodule     */   
assign tick = (q == 103) ? 1 : 0;
 endmodule
