rm(list=ls())

library(data.table)
library(ggplot2)
library(operators)
library(plyr)
library(ggpubr)

### Sesnsitivty Analysis
t =read.csv('../Data/Raw/Sensitivity_Analysis.csv')
p1 <-ggplot(t,aes(x=Paramater,y=P.E,col=Qualitative)) + geom_point() + theme_classic() +
  scale_y_continuous(limits=c(0,1)) +
  labs(x = 'Paramater',y = 'P/E' ,col='') +theme(axis.text.x = element_text(angle=90))
ggsave('../Plots/TableS2.png',p1,height=4,width=4)
fwrite(t,'../Data/Processed/TableS2.csv')

#Main Results
t2 =fread('../Data/Raw/Pairs_Results.csv')
t2[is.na(t2$P_acetate)]$P_acetate =0
taxa = fread('../Data/Biggs_Model_list.csv')
E_species = c('Escherichia','Salmonella','Klebsiella','Shigella','Yersinia')
t2$E_Genus =''
t2$P_Species = 'P.Putida'
t2[P == 'iPB890']$P_Species = 'P.Stutzeri'
t2[P == 'iMO1056']$P_Species = 'P.Aeruginosa'
t2[P == 'iPAU1129']$P_Species = 'P.Aeruginosa'
t2[P == 'iPAE1146']$P_Species = 'P.Aeruginosa'
t2[P == 'iSB1139']$P_Species = 'P.Flourescens'
for(j in E_species){
  g_taxa = taxa[grep(j,taxa$Organism)]
  t2[which(t2$E %in% g_taxa$Models)]$E_Genus=j
}
t2 = data.frame(E = t2$E,P = t2$P, 
                E_Genus = t2$E_Genus, 
                P_Species = t2$P_Species,
                D_ace_glu = abs(t2$ac/t2$glc),
                w_ac_R = t2$P_acetate/t2$ac,
                w_glc_F = abs(t2$E_Glucose/t2$glc))
t2$R_F = t2$D_ace_glu*t2$w_ac_R/t2$w_glc_F
fwrite(t2,'../Data/Processed/Fig1D_S9_S10.csv')


default = t$P.E[t$Qualitative=='Default'][1]
# t2[t2$R_F==0.0,]$R_F=0.0001
p2 <- ggplot(t2,aes(y=R_F,x='FBA')) + geom_boxplot(outlier.size = 0) + 
  geom_jitter(size=0.5,stroke=0.5,shape=4,height=0,width=0.1)+ 
  theme_pubr() + labs(x='')+
  scale_y_log10(limits=c(0.001,10),breaks=c(0.01,0.1,1.0,10.0)) 
ggsave('../Plots/Fig1D.png',p2,height=3,width=4)



p3 <- ggplot(t2[t2$P =='303.176_PID',],aes(y=D_ace_glu,x='FBA')) + geom_boxplot(outlier.size = 0) + 
  geom_jitter(size=0.5,stroke=0.5,shape=4,height=0,width=0.1)+ 
  theme_pubr() + labs(x='')+
  scale_y_continuous(limits=c(0,1.25))
p4 <- ggplot(t2,aes(y=w_ac_R/w_glc_F,x='FBA'))   + geom_boxplot(outlier.size = 0) + 
  geom_jitter(size=0.5,stroke=0.5,shape=4,height=0,width=0.1)+ 
  theme_pubr() + labs(x='')+
  scale_y_continuous(limits=c(0,1.25))
ggsave('../Plots/FigS9.png',ggarrange(p3,p4),height=3,width=6)

med.fac = ddply(t2, .(E_Genus), function(.d) data.frame(x=median(.d$R_F)))
p5 <-ggplot(t2,aes(R_F)) + 
  geom_histogram(colour='green',fill='lightgreen',bins=20) + 
  theme_classic() + labs(x='P(R/F)',y = 'P/E') +
  facet_wrap(~E_Genus,scales='free_y') +
  geom_vline(xintercept = default,col='red',linetype=2) +
  geom_vline(data=med.fac, aes(xintercept=x),col = 'darkblue',linetype=3)
med.fac2 = ddply(t2, .(P_Species), function(.d) data.frame(x=median(.d$R_F)))
p6 <-ggplot(t2,aes(R_F)) + 
  geom_histogram(colour='green',fill='lightgreen',bins=20) + 
  theme_classic() + labs(x='P(R/F)',y = 'P/E') +
  facet_wrap(~P_Species,scales='free_y') + 
  geom_vline(xintercept = default,col='red',linetype=2)  +
  geom_vline(data=med.fac2, aes(xintercept=x),col = 'darkblue',linetype=3)
  
ggsave('../Plots/FigS10.png',ggarrange(p5,p6),height=4,width=8)

t3 = fread('../Data/Raw/Constrained_Secretions.csv')

t3[t3$Condition=='Both']$Condition='Model 2'
t3[t3$Condition=='E_only']$Condition='Model 1'
t3[t3$Condition=='P_only']$Condition='Model 3'

p7 <- ggplot(t3,aes(x=Condition,y=R_F)) + 
  geom_boxplot() + 
  geom_jitter() + 
  theme_classic() + scale_y_log10(breaks= c(0.01,0.3,1.00,10.0),limits=c(0.01,10))
fwrite(t3,'../Data/Processed/FigS16.csv')
ggsave('../Plots/FigS16.png',p7)

t4 = fread('../Data/Raw/Oxygen_Limitation.csv')


t4 = data.frame('Model' = rep(t4$Model,8),
                'R_F' = rep(t4$R_F,8),
                'Condition' = c(rep('Aerobic',nrow(t4)*4),
                                rep('Anaerobic',nrow(t4)*4)),
                'Carbon_Source'=  rep(c(rep('Glucose',nrow(t4)),
                                      rep('Acetate',nrow(t4)),
                                      rep('Lactate',nrow(t4)),
                                      rep('Succinate',nrow(t4))),2),
                'Growth_Rate'  = c(t4$Glucose_Aerobic,
                                   t4$Acetate_Aerobic,
                                   t4$Lactate_Aerobic,
                                   t4$Succinate_Aerobic,
                                   t4$Glucose_Anaerobic,
                                   t4$Acetate_Anaerobic,
                                   t4$Lactate_Anaerobic,
                                   t4$Succinate_Anaerobic))
t4[is.na(t4$Growth_Rate),]$Growth_Rate = 0
t4$Carbon_Source = factor(t4$Carbon_Source,levels=c('Glucose','Acetate','Succinate','Lactate'))
t4$R_F = factor(t4$R_F)
levels(t4$R_F) = c('Enterobacteriaceae','Pseudomonadaceae')
colnames(t4) = c('Model','Family','Oxygen','Carbon_Source','Growth')
t4[t4$Growth>0,]$Growth = TRUE
t4[t4$Growth<=0,]$Growth = FALSE

setDT(t4)[, sum := sum(Growth), by = c("Carbon_Source", "Oxygen","Family")][, N := .N, by = c("Carbon_Source", "Oxygen","Family")][, Proportion := sum/N]
t4 = t4[,c('Family','Oxygen','Carbon_Source','Proportion')]
                            
                            
p8 <- ggplot(t4,aes(x=Carbon_Source,y=Proportion,fill=Oxygen))  + 
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~Family,nrow=2,ncol=1) + theme_pubclean()  + 
  labs(x='',y='Proportion of Metabolic Models that can grow',col = '') +
  scale_fill_manual(values = c('Blue','Orange'))
fwrite(t4,file='../Data/Processed/FigS17.csv')
ggsave('../Plots/FigS17.png',p8)


t5 = fread('../Data/Processed/Whole_Genome_R_F_Pred.csv')

p2_b = ggplot(t2,aes(y=R_F,x='FBA')) + geom_boxplot(outlier.size = 0) + 
  geom_jitter(size=0.5,stroke=0.5,shape=4,height=0,width=0.1,col='grey')+ 
  geom_jitter(t5,mapping=aes(y=R_F,x='FBA'),size=1.0,stroke=1,shape=4,height=0,width=0.1,col='Black')+  
  theme_pubr() + labs(x='')+
  scale_y_log10(limits=c(0.001,10),breaks=c(0.01,0.1,1.0,10.0)) 
p3_b <- ggplot(t2[t2$P =='303.176_PID',],aes(y=D_ace_glu,x='FBA')) + geom_boxplot(outlier.size = 0) + 
  geom_jitter(size=0.5,stroke=0.5,shape=4,height=0,width=0.1,col='grey')+ 
  geom_jitter(t5,mapping=aes(y=D_ace_glu,x='FBA'),size=1.0,stroke=1,shape=4,height=0,width=0.1,col='Black')+  
  theme_pubr() + labs(x='')+
  scale_y_continuous(limits=c(0,1.25))
p4_b <- ggplot(t2,aes(y=w_ac_R/w_glc_F,x='FBA'))   + geom_boxplot(outlier.size = 0) + 
  geom_jitter(size=0.5,stroke=0.5,shape=4,height=0,width=0.1,col='grey')+ 
  geom_jitter(t5,mapping=aes(y=w_ac_R/w_glc_F,x='FBA'),size=1.0,stroke=1,shape=4,height=0,width=0.1,col='Black')+  
  theme_pubr() + labs(x='')+
  scale_y_continuous(limits=c(0,1.25))
ggsave('../Plots/FigS18.png',ggarrange(p3_b,p4_b,p2_b,ncol=3),height =3,width=9)