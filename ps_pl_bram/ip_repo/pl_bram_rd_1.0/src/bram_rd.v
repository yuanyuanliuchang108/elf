
 
module bram_rd(
    output       reg [16:0]   count,
    input                clk        , //ʱ���ź�
    input                rst_n      , //��λ�ź�
    input         [31:0]       start_rd   , //����ʼ�ź�
    input        [31:0]  start_addr , //����ʼ��ַ  
    input        [31:0]  rd_len     , //�����ݵĳ���
    //RAM�˿�
    output               ram_clk    , //RAMʱ��
    input        [31:0]  ram_rd_data, //RAM�ж���������
    output  reg          ram_en     , //RAMʹ���ź�
    output  reg  [31:0]  ram_addr   , //RAM��ַ
    output  reg  [3:0]   ram_we     , //RAM��д�����ź�
    output  reg  [31:0]  ram_wr_data, //RAMд����
    output               ram_rst      //RAM��λ�ź�,�ߵ�ƽ��Ч
);

//reg define
parameter counter_width =16;
parameter depth =4;
parameter width =1024;
reg [31:0] hash_seeds [3:0];
reg [counter_width-1:0]sketch[0:depth-1][0:width-1];
reg  [1:0]   flow_cnt;
reg          start_rd_d0;
reg          start_rd_d1;
reg          start_rd_d01;
reg          start_rd_d11;
reg          start_rd_d02;
reg          start_rd_d12;
reg          start_rd_d03;
reg          start_rd_d13;
reg          start_rd_d04;
reg          start_rd_d14;
reg          start_rd_d05;
reg          start_rd_d15;
reg          start_rd_d06;
reg          start_rd_d16;


reg [16:0] value;
reg[16:0] min= 65535;
reg over=1;
reg [16:0] values [3:0];
//wire define
wire         pos_start_rd;
wire         pos_start_rd1;
wire         pos_start_rd2;
wire         pos_start_rd3;


//*****************************************************
//**                  main code
//*****************************************************
assign  ram_rst = 1'b0;
assign  ram_clk = clk ;
assign pos_start_rd = ~start_rd_d1 & start_rd_d0;
assign pos_start_rd1 = ~start_rd_d11 & start_rd_d01;
assign pos_start_rd2= ~start_rd_d12 & start_rd_d02;
assign pos_start_rd3 = ~start_rd_d13 & start_rd_d03;
assign pos_start_rd4 = ~start_rd_d14 & start_rd_d04;
assign pos_start_rd5 = ~start_rd_d15 & start_rd_d05;
assign pos_start_rd6 = ~start_rd_d16 & start_rd_d06;


//��ʱ���ģ���start_rd�źŵ�������
integer i, j,k,g;

    initial begin
        for (i = 0; i < depth; i = i + 1) begin
            for (j = 0; j < width; j = j + 1) begin
                sketch[i][j] <= 0;
            end
        end
      
           hash_seeds[0]<=2566;
           hash_seeds[1]<=1949;
           hash_seeds[2]<=6666;
           hash_seeds[3]<=8888;
           count<=0;
           values[0]<=0;
           values[1]<=0;
           values[2]<=0;
           values[3]<=0;
    end
    
    
    





always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        start_rd_d0 <= 1'b0;   
        start_rd_d1 <= 1'b0; 
    end
    else begin
        start_rd_d0 <= start_rd[0];   
        start_rd_d1 <= start_rd_d0;
           start_rd_d01 <= start_rd[1];   
        start_rd_d11 <= start_rd_d01;
           start_rd_d02 <= start_rd[2];   
        start_rd_d12 <= start_rd_d02;
           start_rd_d03 <= start_rd[3];   
        start_rd_d13 <= start_rd_d03;
                start_rd_d04 <= start_rd[4];   
        start_rd_d14 <= start_rd_d04;
           start_rd_d05 <= start_rd[5];   
        start_rd_d15 <= start_rd_d05;
           start_rd_d06 <= start_rd[6];   
        start_rd_d16 <= start_rd_d06;

             
    end
end

//���ݶ���ʼ�ź�,��RAM�ж�������
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        flow_cnt <= 2'd0;
        ram_en <= 1'b0;
        ram_addr <= 32'd0;
        ram_we <= 4'd0;
    end
    else begin
        case(flow_cnt)
            2'd0 : begin
                if(pos_start_rd ) begin
                    ram_en <= 1'b1;
                    ram_addr <= start_addr;
                   
                    flow_cnt<= flow_cnt + 2'd1;
                                          end
                    end
    
            2'd1 : begin
                if(ram_addr - start_addr == rd_len - 4) begin  //���ݶ���
                
               
                    ram_en <= 1'b0;
                    flow_cnt <= flow_cnt + 2'd1;
                                                         end
                else  begin
                     ram_addr <= ram_addr + 32'd4;
                      end            
                     end
   
            2'd2 : begin
                ram_addr <= 32'd0; 
         flow_cnt<=2'd0;
                    end
        endcase    
        
    end
end



//д�����
always @(posedge clk ) begin


      
                 if(pos_start_rd1  ) begin
     
            values[0]<=(ram_rd_data % hash_seeds[0])%1024;
 values[1]<=(ram_rd_data % hash_seeds[1])%1024;
        values[2]<=(ram_rd_data % hash_seeds[2])%1024;
        values[3]<=(ram_rd_data % hash_seeds[3])%1024;
    end
end





always @(posedge clk ) begin


      
                 if( pos_start_rd2 && over) begin
     
            
                   
                    sketch[0][values[0]]<=sketch[0][values[0]]+1;
             sketch[1][values[1]]<=sketch[1][values[1]]+1;
              sketch[2][values[2]]<=sketch[2][values[2]]+1;
               sketch[3][values[3]]<=sketch[3][values[3]]+1;
                    over<=0;
                    end
 
        
    end


//����over
always @(posedge clk) begin


      
                 if(pos_start_rd3 ) begin
     
            over<=1;
                    end
 
        
    end




always @(posedge clk ) begin

 if(pos_start_rd4)begin
   min = 65535;
  if(min > sketch[0][values[0]])begin
  min=sketch[0][values[0]];
  end
             if(min > sketch[1][values[1]])begin
  min=sketch[1][values[1]];
  end           
        
    if(min > sketch[2][values[2]])begin
  min=sketch[2][values[2]];
  end
      if(min > sketch[3][values[3]])begin
  min=sketch[3][values[3]];
  end
 

    end
    count=min;
    end

endmodule




