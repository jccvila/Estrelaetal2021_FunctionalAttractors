rm(list=ls())
library(curl)
library(data.table)

### Extract list
t= readLines('../Data/model_list.txt')
t = substr(t,start = head(gregexpr("\\[",t)[[1]],1)+1,stop = tail(gregexpr("\\]",t)[[1]],1)-1)
start = gregexpr("\\{",t)[[1]]
stop = gregexpr("\\}",t)[[1]]
df = data.frame(Models  = as.character(),Genes = as.numeric(),Metabolites  = as.numeric(),Reactions = as.numeric(),Organism = as.numeric())
for(i in 1:length(start)){
  temp = substr(t,start[i]+1,stop[i]-1)
  temp = strsplit(temp,',')[[1]]
  model  = strsplit(temp[grep('bigg_id',temp)],':')[[1]][2]
  model = substr(model,3,nchar(model)-1)
  gn = as.numeric(strsplit(temp[grep('gene_count',temp)],':')[[1]][2])
  rn = as.numeric(strsplit(temp[grep('reaction_count',temp)],':')[[1]][2])
  mn = as.numeric(strsplit(temp[grep('metabolite_count',temp)],':')[[1]][2])
  on = strsplit(temp[grep('organism',temp)],':')[[1]][2]
  on = substr(on,3,nchar(on)-1)
  df = rbind(df,data.frame(Models = model,Genes = gn, Reactions = rn, Metabolites = mn, Organism = on))
}

for(i in df$Models){
  curl_download(url=paste('http://bigg.ucsd.edu/static/models/',i,'.xml',sep=''),destfile = paste('../Data/Bigg_Model/',i,'.xml',sep=''))
}

fwrite(df,file='../Data/Biggs_Model_list.csv')
