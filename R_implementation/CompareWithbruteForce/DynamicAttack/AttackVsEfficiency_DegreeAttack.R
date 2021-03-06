library(igraph)
library(gridExtra)
library(ggplot2)



n0<-10
maxNumberOfAttacks<-3
attackSeq<-seq(0,maxNumberOfAttacks,by=1)
set.seed(123)
g0 <- sample_pa(n0,directed = F)
V(g0)$name <-V(g0)



type<-"AttackVsEfficiency_"
attackMethod<-"Degree"
Linklimit<-5




#####################functions
findAttack<-function(g,k){
    
    if(k!=0){
        a1<-vector()
        gtmp<-g
        for(i in 1:k){
            dg<-degree(gtmp)
            at<-names(dg[which(dg==max(dg))])[1]
            a1<-c(a1,at)
            gtmp<-delete.vertices(gtmp,at)
        }
        a1   
    }
    else 
        NA
}
 
graphAfterAttackWith<-function(g,at){
    if(is.na(at[1]))
        g
    else{
        gTemp<-delete.vertices(g,at)
        gTemp2<-add.vertices(gTemp,length(at),name=at)
        gTemp2
    }
        
}


graphAfterAttackWithout<-function(g,at){
    if(is.na(at[1]))
        g
    else{
        gTemp<-delete.vertices(g,at)
        gTemp
    }
        
}
    
findEfficiency<-function(g,at){
    gTemp<-graphAfterAttackWith(g,at)
    dtr<-distance_table(gTemp,directed = F)$res
    e<-2*sum(dtr*(1/(1:length(dtr))))/(vcount(gTemp)*(vcount(gTemp)-1))
    e
}
    
findVulnerability<-function(g,at){
        if(findEfficiency(g,NA)!=0)
            (1-(findEfficiency(g,at)/findEfficiency(g,NA)))
        else 
            0
}
    
getCombinations<-function(g){
     d<-degree(g)
     combinations<-combn(d,2,simplify = F)
     combinations
}

getallCombinations<-function(g){
  d<-degree(g)
  combinations<-combn(d,2,simplify = F)
  combinations2<-combn(1:length(combinations),Linklimit,simplify = F)
  combinations3<-list()
  z<-1
  
  for(i in 1:length(combinations2)){
    print(i)
    combinations3[[z]]<-combinations[combinations2[[i]]]
    z<-z+1
  }
  
  
  combinations3
}

    

####### add links    

t<-0
Flag<-1
k<-maxNumberOfAttacks  



at0<-findAttack(g0,k)
vul0<-findVulnerability(g0,at0)
ef0<-findEfficiency(g0,at0)

g<-g0

vul<-vul0
ef<-ef0




while(t<Linklimit && Flag){
        
    print(t)
    
    at<-findAttack(g,k)
    gAt<-graphAfterAttackWithout(g,at)
        
    combinations<-getCombinations(gAt)
    
    benefit<-sapply(combinations,function(x){
        n<-names(x)
        gTmp<-g+edge(n[1],n[2])
        at<-findAttack(gTmp,k)
        vull<-findVulnerability(gTmp,at)
        vul-vull
    })
        
    if(length(which(benefit>0))==0){
        Flag<-0
    }
            
    else{
        selectedCom<-combinations[[which(benefit==max(benefit))[1]]]
        n<-names(selectedCom)
        g<-g+edge(n[1],n[2])
        at<-findAttack(g,k)
        vul<-findVulnerability(g,at)
        ef<-findEfficiency(g,at)
        t<-t+1
            
    }
}




############intialize vectors


efAfter<-vector()
efPref<-vector()
efInvPref<-vector()
efRand<-vector()


####### add randomly/preferential and inverse preferential

grand<-g0

c<-getallCombinations(grand)


at0<-findAttack(g0,maxNumberOfAttacks)
e0<-findVulnerability(g0,at0)

maxI<-1
grand<-g0
for(j in 1:5){
    n<-names(c[[1]][[j]])
    grand<-grand+edge(n[1],n[2])  
    
}
at<-findAttack(grand,maxNumberOfAttacks)
max<-e0-findVulnerability(grand,at)


for(i in 2:length(c)){
    grand<-g0
    for(j in 1:5){
        n<-names(c[[i]][[j]])
        grand<-grand+edge(n[1],n[2])  
        
    }
    at<-findAttack(grand,maxNumberOfAttacks)
    w<-e0-findVulnerability(grand,at)
    if(w>max){
        maxI<-i
        max<-w
        print(max)
       
    }
    
    print(i)
}




selectedCom<-c[[maxI]]
grand<-g0
for(j in 1:5){
  
  grand<-grand+edge(names(selectedCom[[j]])[1],names(selectedCom[[j]])[2])  
  print(ecount(grand))
  
}


###attack graphs

for(k in attackSeq){   
    
    
    
    ####################
    at<-findAttack(grand,k)
    efRand<-c(efRand,findEfficiency(grand,at))
    ####################
    at<-findAttack(g,k)
    efAfter<-c(efAfter,findEfficiency(g,at))

    print(k)
    
}

###################################plot result###########################
df<-cbind.data.frame(attackSeq,efAfter,efRand)
names(df)<-c("numberOfAttacks","efAfter","efRand")





efPlot<-ggplot(df, aes(x = numberOfAttacks)) + 
    geom_line(aes(y = efAfter, colour="Our Add")) + 
   # geom_line(aes(y = efPref, colour = "Preferential Add")) + 
  #  geom_line(aes(y = efInvPref, colour = "Inverse Preferential Add"))+
    geom_line(aes(y = efRand, colour = "Random Add")) +
    ylab(label="Efficiency After Attack") + 
    xlab("Number of Attacks")+
    scale_colour_manual(values=c("blue", "red"))+
    scale_x_continuous(breaks=attackSeq)


st1<-paste0(type,"_",attackMethod,"_",n0,"_",maxNumberOfAttacks,"_",Linklimit,".png")
png(st1, width = 800)
print(efPlot)
dev.off()

