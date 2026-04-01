// alu_32.sv 
// ALU de 32 bits com carry out para a versao refinada do multiplicador
// Baseado na Figura 3.5 - Patterson & Hennessy, Computer Organization and Design
//
// Na versao refinada, a ALU opera sobre os 32 bits superiores do registrador
// product e o multiplicando de 32 bits. O carry out e preservado e inserido
// no bit 63 do product apos o deslocamento a direita.

module alu_32 (
    input  logic [31:0] a,
    input  logic [31:0] b,
    output logic [31:0] sum,
    output logic        carry_out
);
    assign {carry_out, sum} = {1'b0, a} + {1'b0, b};
endmodule