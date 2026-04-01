// multiplier_control.sv
// FSM de controle da versao refinada do multiplicador
//
// Fluxograma da versao refinada (uma iteracao por ciclo):
//
//   1. Testar Product[0] (LSB do registrador product, equivale ao Multiplier0)
//   2. Se Product[0] == 1 → Product[63:32] = Product[63:32] + Multiplicand
//      (passos 1 e 2 combinados com o shift no mesmo ciclo)
//   3. Shift Product a direita 1 bit (carry do passo 2 vai para Product[63])
//   4. 32a. repeticao? → Sim: Fim | Nao: voltar ao passo 1
//
// Diferenças em relacao a versao original:
//   - Estados ADD_OR_SKIP e SHIFT fundidos em COMPUTE (add + shift em 1 ciclo)
//   - multiplier_lsb nao e mais exposto pela FSM (testado internamente no datapath)
//   - product_wr e shift_en substituidos por compute_en
//   - Total: ~34 ciclos (1 LOAD + 32 COMPUTE + 1 DONE)
//     vs. ~66 ciclos da versao original (1 LOAD + 32×2 + 1 DONE)
//
// Estados:
//   IDLE    — aguarda sinal 'start'
//   LOAD    — carrega operandos no datapath (1 ciclo)
//   COMPUTE — executa uma iteracao add+shift; repete 32 vezes (count 0..31)
//   DONE    — sinaliza conclusao; retorna a IDLE quando 'start' é resetado

module multiplier_control (
    input  logic clk,
    input  logic rst_n,

    // Interface com o usuario
    input  logic start,
    output logic done,

    // Interface com o datapath
    output logic load,        // Carrega operandos iniciais
    output logic compute_en   // Executa uma iteracao (add condicional + shift)
);

    // Implemente o modulo aqui

endmodule
