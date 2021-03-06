library(igraph)
library(gridExtra)
library(ggplot2)



n0<-100
maxNumberOfAttacks<-10
attackSeq<-seq(0,maxNumberOfAttacks,by=1)
set.seed(123)
g0 <- sample_pa(n0,directed = F)
V(g0)$name <-V(g0)



type<-"ModifiedAddedLinksVsRobustness_"
attackMethod<-"Degree"
Linklimit<-50




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


findRobustness<-function(g){
    
    
    at<-findAttack(g,maxNumberOfAttacks)
    names<-names(V(g))
    n<-vcount(g)
    efsum<-0
    m<-distances(g)
    rname<-row.names(m)
    for(i in at){
        #with<-graphAfterAttackWith(g,i)
        #without<-graphAfterAttackWithout(g,i)

        
        l<-which(rname==i)
        m2<-m[-l,-l]
       
        sum<-0
        for(j in 1:(nrow(m2)-1)){
            for(k in (j+1):ncol(m2)){
                sum<-sum+(1/m2[j,k])
                #print((1/m2[i,j]))
            }
        }
        
        efg<-(2*sum)
      
        efsum<-efsum-(findEfficiency(g,i)*n*(n-1))+efg

    }
    1-(efsum/(maxNumberOfAttacks*(n-1)*(n-2)))
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



############intialize vectors


rbsAfter<-findRobustness(g0)
rbsPref<-findRobustness(g0)
rbsInvPref<-findRobustness(g0)
rbsRand<-findRobustness(g0)

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
        rbsAfter<-c(rbsAfter,findRobustness(g))    
    }
    
    
    ###########random
    grand<-g0
    set.seed(123)
    d<-degree(grand)
    namesOfnodes<-names(d)
    for(e in 1:t){
        
        candidate<-sample(namesOfnodes,2,replace = F)
        while(are_adjacent(grand,candidate[1],candidate[2])){
            candidate<-sample(namesOfnodes,2,replace = F)
        }
        grand<-grand+edge(candidate[1],candidate[2])
        
    }
    rbsRand<-c(rbsRand, findRobustness(grand))
    
    
    #####inverse preferential   
    gInversePref<-g0
    set.seed(123)
    d<-degree(gInversePref)
    s<-sum(sapply(d,function(x)1/x))
    namesOfnodes<-names(d)
    for(e in 1:t){
        
        ps<-sapply(d, function(x)((1/x)/s))
        candidate<-sample(namesOfnodes,2,replace = F, prob = ps)
        while(are_adjacent(gInversePref,candidate[1],candidate[2])){
            candidate<-sample(namesOfnodes,2,replace = F)
        }
        gInversePref<-gInversePref+edge(candidate[1],candidate[2])
        
    }
    rbsInvPref<-c(rbsInvPref,findRobustness(gInversePref))
    
    #################preferential
    gPref<-g0
    set.seed(123)
    d<-degree(gPref)
    s<-sum(d)
    namesOfnodes<-names(d)
    for(e in 1:t){
        ps<-sapply(d, function(x)x/s)
        candidate<-sample(namesOfnodes,2,replace = F, prob = ps)
        while(are_adjacent(gPref,candidate[1],candidate[2])){
            candidate<-sample(namesOfnodes,2,replace = F)
        }
        gPref<-gPref+edge(candidate[1],candidate[2])
    
    }
    rbsPref<-c(rbsPref,findRobustness(gPref))
    
    
}






####### add randomly/preferential and inverse preferential







###################################plot result###########################
df<-cbind.data.frame((0:Linklimit),rbsAfter,rbsPref,rbsInvPref,rbsRand)
names(df)<-c("numberOfLinks","rbsAfter","rbsPref","rbsInvPref","rbsRand")





rbsPlot<-ggplot(df, aes(x = numberOfLinks)) + 
    geom_line(aes(y = rbsAfter, colour="Our Add")) + 
    geom_line(aes(y = rbsPref, colour = "Preferential Add")) + 
    geom_line(aes(y = rbsInvPref, colour = "Inverse Preferential Add"))+
    geom_line(aes(y = rbsRand, colour = "Random Add")) +
    ylab(label="Robustness") + 
    xlab("Number of Added Links")+
    scale_colour_manual(values=c("blue", "red","green","pink"))+
    scale_x_continuous(breaks=df$numberOfLinks)


st1<-paste0(type,"_",attackMethod,"_",n0,"_",maxNumberOfAttacks,"_",Linklimit,".png")
png(st1, width = 800)
print(rbsPlot)
dev.off()

