library(igraph)
library(gridExtra)
library(ggplot2)



n0<-100
maxNumberOfAttacks<-10
attackSeq<-seq(0,maxNumberOfAttacks,by=1)
set.seed(123)
g0 <- sample_pa(n0,directed = F)
V(g0)$name <-V(g0)



type<-"FailureVsEfficiency_"
attackMethod<-"Degree"
Linklimit<-20




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


findFailure <-function(g,k){
    dg<-degree(g)
    if(k!=0){
      names(sample(dg, k,replace = F))
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
efBefore<-vector()
efgr<-vector()



#######create random graph of same size as added


set.seed(123)
gr<-erdos.renyi.game(n=n0,p.or.m = (ecount(g0))+Linklimit,type = "gnm")
V(gr)$name <-V(gr)


##############################attack graphs

gt1<-g0
gt2<-gr
gt3<-g

set.seed(123)
###########attack original
at0<-findFailure(gt1,0)
efBefore<-c(efBefore,findEfficiency(gt1,at0))
##################attack updated 
set.seed(123)
atr<-findFailure(gt2,0)
efgr<-c(efgr,findEfficiency(gt2,atr))
####################attack random
set.seed(123)
at<-findFailure(gt3,0)
efAfter<-c(efAfter,findEfficiency(gt3,at))

at<-c()
for(k in 2:length(attackSeq)){   
    
    set.seed(123)
    at<-c(at,findFailure(gt1,1))
    gt1<-delete.vertices(gt1,tail(at,1))
    print(k)
    
}


for(k in 1:(length(attackSeq)-1)){   
    
   
    efBefore<-c(efBefore,findEfficiency(g0,at[1:k]))

    efgr<-c(efgr,findEfficiency(gr,at[1:k]))
  
    efAfter<-c(efAfter,findEfficiency(g,at[1:k]))
 
    
    print(k)
    
}


###################################plot result###########################
df<-cbind.data.frame(attackSeq,efAfter,efBefore,efgr)
names(df)<-c("numberOfAttacks","efAfter","efBefore","efgr")


efPlot<-ggplot(df, aes(x = numberOfAttacks)) + 
    geom_line(aes(y = efAfter, colour="After Adding Links")) + 
    geom_line(aes(y = efBefore, colour = "Before Adding Links")) + 
    geom_line(aes(y = efgr, colour = "Random graph"))+
    ylab(label="Efficiency After Failure") + 
    xlab("Number of Failures")+
    scale_colour_manual(values=c("blue", "red","green"))+
    scale_x_continuous(breaks=attackSeq)

st1<-paste0(type,"_",attackMethod,"_",n0,"_",maxNumberOfAttacks,"_",Linklimit,".png")
png(st1, width = 800)
print(efPlot)
dev.off()

