## import re
import numpy as np
import pandas as pd
import itertools
import cobra as c
import matplotlib.pyplot as plt
from CAFBAFY import *
from os import *

if not path.exists('../Data/Pseudomonadaceae'):
    makedirs('../Data/Pseudomonadaceae')
if path.exists('../Data/Pseudomonadaceae/irrev_iJN1463.xml'):
    P = CAFBA_Model(c.io.read_sbml_model('../Data/Pseudomonadaceae/irrev_iJN1463.xml'))
    P.solver='cplex'
    P.set_minimal_media()
    P.reactions.EX_ac_e.lower_bound =-10
    P.optimize()
else:
    P = CAFBA_Model(c.io.read_sbml_model('../Data/Bigg_Model/iJN1463.xml'))
    P.irreversabilize()
    P.solver='cplex'
    P.set_minimal_media()
    P.reactions.EX_ac_e.lower_bound =-10
    P.optimize()
    P.summary()
    P.save('../Data/Pseudomonadaceae/irrev_iJN1463.xml')

gene_ontology_matrix = pd.read_csv('../Data/Pputida_Models.csv')
#Load Pputida model
for k in gene_ontology_matrix.columns[1:]:
    if path.exists('../Data/Pseudomonadaceae/' + k):
        continue
    if k == 'KT2440.csv_PID' or k =='160488.4.RefSeq_PID':
        continue
    print('trying gapfilling for ' + k)
    scores =gene_ontology_matrix[k]
    genes_to_delete = list(gene_ontology_matrix.locus[(scores<80) | np.isnan(scores)])
    genes_to_delete = [x for x in genes_to_delete if x in P.genes]
    if len(genes_to_delete) > 300:
        print('to many genes to gene to delete for ' + k)
        continue
    try:
        P.solver='cplex'
        P2 = P.copy()
        # delete reaction
        c.manipulation.delete_model_genes(P2, genes_to_delete)
        P2.prune_model()
        #confirm it can't groww
        P2.optimize()
        P2.summary()
        # gapfill mutant using original putida model
        gf = cobra.flux_analysis.gapfilling.GapFiller(P2,P, integer_threshold=1e-20,demand_reactions=False)
        gapfill_solution = gf.fill()
        P2.add_reactions(gapfill_solution[0])
        P2.save('../Data/Pseudomonadaceae/' + k)
        print('succesful gapfilling for ' + k)
    except:
        P.solver='glpk'
        P2 = P.copy()
        # delete reaction
        c.manipulation.delete_model_genes(P2, genes_to_delete)
        P2.prune_model()
        #confirm it can't groww
        P2.optimize()
        P2.summary()
        # gapfill mutant using original putida model
        gf = cobra.flux_analysis.gapfilling.GapFiller(P2,P, integer_threshold=1e-20,demand_reactions=False)
        gapfill_solution = gf.fill()
        P2.add_reactions(gapfill_solution[0])
        P2.save('../Data/Pseudomonadaceae/' + k)
        print('succesful gapfilling for ' + k)        
