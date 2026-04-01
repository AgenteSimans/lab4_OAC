// multiplier_datapath.sv
// Datapath da versao refinada do multiplicador de 32 bits
// Baseado na Figura 3.5 - Patterson & Hennessy, Computer Organization and Design
// Secao "Sequential Version of the Multiplication Algorithm", pp. 194-196
//
// Diferencas em relacao a versao original (Figura 3.3):
//
//   Versao original           │  Versao refinada
//   ──────────────────────────┼────────────────────────────────────────
//   multiplicand_reg [63:0]   │  multiplicand_reg [31:0]  (sem shift)
//   multiplier_reg   [31:0]   │  eliminado
//   product_reg      [63:0]   │  product_reg [63:0] = {0, multiplier}
//   ALU 64 bits               │  ALU 32 bits + carry out
//   shift left multiplicand   │  sem shift no multiplicando
//   shift right multiplier    │  shift right do product completo
//   add e shift em 2 ciclos   │  add + shift combinados em 1 ciclo
//
// Operacao a cada ciclo COMPUTE:
//   Testa product_reg[0] (LSB atual, bit do multiplicador desta iteracao)
//   Se 1 : product_reg <= {carry, sum[31:0], product_reg[31:1]}
//            onde {carry, sum} = product_reg[63:32] + multiplicand_reg
//   Se 0 : product_reg <= {1'b0, product_reg[63:1]}
//
//   Em ambos os casos, o resultado e equivalente ao deslocamento a direita
//   do valor de 65 bits {carry, sum[31:0], product_reg[31:0]}.

module multiplier_datapath (
    input  logic        clk,
    input  logic        rst_n,

    // Entradas de dados
    input  logic [31:0] multiplicand_in,
    input  logic [31:0] multiplier_in,

    // Sinais de controle vindos da FSM
    input  logic        load,        // Carrega operandos iniciais
    input  logic        compute_en,  // Executa uma iteracao (add condicional + shift)

    // Saida do resultado
    output logic [63:0] product
);

    // -----------------------------------------------------------------------
    // Registradores internos (Figura 3.5)
    // -----------------------------------------------------------------------
    logic [31:0] multiplicand_reg;  // Constante apos LOAD (32 bits, sem shift)
    logic [63:0] product_reg;       // Inicializado com {32'b0, multiplier}

    // -----------------------------------------------------------------------
    // ALU de 32 bits (Figura 3.5 — opera sobre os 32 bits superiores do product)
    // -----------------------------------------------------------------------
    logic [31:0] alu_sum;
    logic        alu_carry;

    alu_32 alu (
        .a         (product_reg[63:32]),  // 32 bits superiores do product
        .b         (multiplicand_reg),
        .sum       (alu_sum),
        .carry_out (alu_carry)
    );

    // -----------------------------------------------------------------------
    // Saida combinacional
    // -----------------------------------------------------------------------
    assign product = product_reg;

    // -----------------------------------------------------------------------
    // Atualizacao dos registradores
    // -----------------------------------------------------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            multiplicand_reg <= '0;
            product_reg      <= '0;

        end else if (load) begin
            //   Multiplicand -> registrador de 32 bits (permanece constante)
            //   Product      -> {32'b0, multiplier} (bits do multiplicador nos [31:0])
            multiplicand_reg <= multiplicand_in;
            product_reg      <= {32'b0, multiplier_in};

        end else if (compute_en) begin
            // Add condicional + shift a direita em um unico ciclo (pp. 194-196)
            //
            // Se product_reg[0] == 1:
            //   Equivale ao shift a direita do valor de 65 bits
            //   {alu_carry, alu_sum[31:0], product_reg[31:0]}
            //   -> {alu_carry, alu_sum[31:0], product_reg[31:1]}  (descarta bit 0)
            //
            // Se product_reg[0] == 0:
            //   Shift a direita simples, inserindo 0 no bit 63
            if (product_reg[0])
                product_reg <= {alu_carry, alu_sum, product_reg[31:1]};
            else
                product_reg <= {1'b0, product_reg[63:1]};
        end
    end

endmodule