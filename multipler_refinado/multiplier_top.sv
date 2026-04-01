// multiplier_top.sv
// Módulo top-level da versao refinada do multiplicador de 32 bits
// Baseado nas Figuras 3.5 - Patterson & Hennessy, pp. 194-196
//
// Uso:
//   1. Apresentar os operandos em 'multiplicand_in' e 'multiplier_in'
//   2. Setar 'start' por pelo menos 1 ciclo de clock
//   3. Aguardar 'done' ser setado (após 34 ciclos: 1 LOAD + 32 COMPUTE + 1 DONE)
//   4. Ler o produto de 64 bits em 'product'
//   5. Resetar 'start' para permitir nova operacao

module multiplier_top (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        start,           // Inicia a multiplicação
    input  logic [31:0] multiplicand_in, // Operando A (32 bits)
    input  logic [31:0] multiplier_in,   // Operando B (32 bits)

    output logic [63:0] product,         // Resultado A × B (64 bits)
    output logic        done             // Indica término da operação
);

    // -----------------------------------------------------------------------
    // Sinais internos entre controle e datapath
    // -----------------------------------------------------------------------
    logic load;
    logic compute_en;

    // -----------------------------------------------------------------------
    // Instancia do datapath (Figura 3.7)
    // -----------------------------------------------------------------------
    multiplier_datapath datapath (
        .clk             (clk),
        .rst_n           (rst_n),
        .multiplicand_in (multiplicand_in),
        .multiplier_in   (multiplier_in),
        .load            (load),
        .compute_en      (compute_en),
        .product         (product)
    );

    // -----------------------------------------------------------------------
    // Instancia da FSM de controle
    // -----------------------------------------------------------------------
    multiplier_control control (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .done       (done),
        .load       (load),
        .compute_en (compute_en)
    );

endmodule