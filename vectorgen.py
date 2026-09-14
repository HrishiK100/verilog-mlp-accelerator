import numpy as np
rng = np.random.default_rng(42) # seed for repoducibility

N = 16 # inputs per neuron
NUM_VEC = 20 # test vectors


weights = rng.integers(-128, 128, size=N, dtype=np.int32)
bias = np.int32(rng.integers(-5000, 5000))

inputs = rng.integers(-128, 128, size=(NUM_VEC, N), dtype=np.int32)


# neuron function
def neuron(w, x, b, shift):
    #dot product
    acc = np.int32(np.dot(w.astype(np.int32), x.astype(np.int32)))
    #add bias
    acc = np.int32(acc + b)
    #relu
    acc = np.int32(max(int(acc),0))
    #shift
    acc = np.int32(acc >> shift)

    return int(min(int(acc), 127))



#try to find the best shift value for the neuron function
def score(shift):
    #apply the neuron function to all inputs
    outs = [neuron(weights, x, bias, shift) for x in inputs]

    #calculate the score
    return sum(20 <= o <= 120 for o in outs), outs

best_shift, best_hits, best_outs = None, -1, None

#loop to find the best shift value
for s in range(4, 20):
    hits, outs = score(s)
    if hits > best_hits:
        best_hits = hits
        best_shift = s
        best_outs = outs
    
#assign the best shift value and outputs
SHIFT = best_shift
outputs = best_outs

#output so verilog can read
def to_hex(x):
    return f"{int(x) & 0xFF:02X}"

with open("weights.hex", "w") as f:
    for w in weights:
        f.write(to_hex(w) + "\n")

with open("inputs.hex", "w") as f:
    for vec in inputs:
        for x in vec:
            f.write(to_hex(x) + "\n")

with open("expected.hex", "w") as f:
    for o in outputs:
        f.write(to_hex(o) + "\n")


#report
print(f"SHIFT      = {SHIFT}   ({best_hits}/{NUM_VEC} outputs in 20..120)")
print(f"BIAS       = {int(bias)}  (hex {int(bias) & 0xFFFFFFFF:08x})")
print(f"weights    = {list(map(int, weights))}")
print(f"outputs    = {outputs}")
 
#make-sure that check when all inputs are 0, the output is max(0,bias)>>SHIFT
zero_in = np.zeros(N, dtype=np.int32)
print(f"\nsanity A (zero input)      -> {neuron(weights, zero_in, bias, SHIFT)}"
      f"   expected max(0,bias)>>SHIFT sat = "
      f"{min(max(int(bias),0) >> SHIFT, 127)}")
 
#make sure check that when all inputs are weights, the output saturates at 127
print(f"sanity B (w as input)      -> {neuron(weights, weights, bias, SHIFT)}"
      f"   (want 127)")
 
# raw pre-shift magnitude, useful when debugging the Verilog accumulator
raw = int(np.dot(weights, inputs[0])) + int(bias)
print(f"\nvector 0 raw acc+bias      = {raw}  (hex {raw & 0xFFFFFFFF:08x})")
print(f"vector 0 expected output   = {outputs[0]} (hex {to_hex(outputs[0])})")