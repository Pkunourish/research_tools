import numpy as np

legend_map = {
        "s0":"Loops",
        "s1":"Breaks",
        "s2":"Bends",
        "s3":"Turns",
        "s4":"PP_Helics",
        "s5":"pi-Helics",
        "s6":"310-Helics",
        "s7":"beta-Strands",
        "s8":"beta-Bridges",
        "s9":"alpha-Helics"
}

with open("dssp.xvg", "r") as f:
    lines = f.readlines()

data_lines = [line.strip().split() for line in lines if not line.startswith(("@","#"))]
data = np.array(data_lines, dtype = float)

time = data [:, 0]
ss_counts = data[:, 1:11]

total_residues = np.sum(ss_counts,axis =1)

ss_percent = (ss_counts / total_residues[:, np.newaxis])

with open("dssp_percentage_apo.txt","w") as f:
    for i in range (len(time)):
        line = f"{time[i]:.1f}" + " " +  " ".join([f"{x:.2f}" for x in ss_percent[i]]) + "\n"
        f.write(line)

print("Finished!")


