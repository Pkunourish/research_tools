import csv

def extract_sdf_titles(sdf_path):
    with open(sdf_path, 'r') as f:
        mol_blocks = [b.strip() for b in f.read().split('$$$$\n') if b.strip()]
    
    hit_ids = []
    for block in mol_blocks:
        first_line = block.split('\n', 1)[0].strip()
        
        if '.' in first_line:
            hit_id = first_line.split('.', 1)[0]
        else:
            hit_id = first_line 
        
        hit_ids.append(hit_id)
    
    return hit_ids

input_file = "ATP4round3.sdf"
output_file = "hit_ids.csv"

ids = extract_sdf_titles(input_file)

with open(output_file, 'w', newline='') as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["HIT_ID"])  
    writer.writerows([[hit_id] for hit_id in ids])

print("success")
