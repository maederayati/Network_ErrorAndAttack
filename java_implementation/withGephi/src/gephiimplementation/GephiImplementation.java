/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package gephiimplementation;
import java.lang.*;
import java.util.Collections.*;
import java.io.*;
import java.util.*;
import java.io.File;
import java.util.ArrayList;
import java.util.stream.Collectors;
import org.gephi.graph.api.GraphController;
import org.gephi.graph.api.GraphModel;
import org.gephi.io.importer.api.Container;
import org.gephi.io.importer.api.ImportController;
import org.gephi.io.processor.plugin.DefaultProcessor;
import org.gephi.project.api.ProjectController;
import org.gephi.project.api.Workspace;
import org.openide.util.Lookup;

import org.gephi.graph.api.GraphModel.*;

import org.gephi.graph.api.*;

import org.gephi.graph.api.*;
import org.gephi.project.api.ProjectController;
import org.gephi.project.api.Workspace;
import org.openide.util.Lookup;


import org.gephi.io.importer.api.*;
import org.gephi.io.processor.plugin.DefaultProcessor;
import org.gephi.io.importer.spi .*;

import org.gephi.statistics.plugin.*;
import org.gephi.data.attributes.api.*;
import org.gephi.io.exporter.api.*;
import org.gephi.statistics.plugin.GraphDistance;

import org.gephi.graph.api.GraphModel;
import org.gephi.algorithms.shortestpath.*;
/**
 *
 * @author marayati
 */
public class GephiImplementation {

    /**
     * @param args the command line arguments
     * @throws java.io.IOException
     */
    public static void main(String[] args) throws IOException {
        // TODO code application logic here
        //int n0=100;
        int maxNumberOfAttacks=10;
        String type="AttackVsEfficiency_";
        String attackMethod="Betweenness";
        int Linklimit=20;
        ArrayList<Integer> attackSeq=new ArrayList<>();
        for(int i=0;i<(maxNumberOfAttacks+1);i++)
            attackSeq.add(i);
        
        
        //Gephi initialization
        ProjectController pc = Lookup.getDefault().lookup(ProjectController.class);
        pc.newProject();
        Workspace workspace = pc.getCurrentWorkspace();
        GraphModel graphModel = Lookup.getDefault().lookup(GraphController.class).getModel();
        AttributeModel attributeModel = Lookup.getDefault().lookup(AttributeController.class).getModel();

	//Get controllers and models
        ImportController importController = Lookup.getDefault().lookup(ImportController.class);

      	//----adding a new attribute - criticality = betweenness/degree
	//AttributeTable nodeTable = attributeModel.getNodeTable();

	//AttributeColumn criticality = nodeTable.addColumn("Criticality",AttributeType.DOUBLE);

        //Import file
        Container container;
        try {
            File file = new File("./scalefree123.gml");
            container = importController.importFile(file);
            container.getLoader().setEdgeDefault(EdgeDefault.UNDIRECTED);   //Force UNDIRECTED
        } catch (Exception ex) {
            ex.printStackTrace();
            return;
        }

        //Append imported data to GraphAPI
        importController.process(container, new DefaultProcessor(), workspace);
        
        
        UndirectedGraph g0 = graphModel.getUndirectedGraph();
        
        
        int t=0;
        boolean flag=true;
        int k=maxNumberOfAttacks;
        ArrayList<Node> at0=findAttack(g0,k);
        double vul0=findVulnerability(g0,at0);
        double ef0=findEfficiency(g0,at0);
        UndirectedGraph g=copyGraph(g0);
        double vul=vul0;
        double ef=ef0;
        ArrayList<Node> at;
                
        
        
    while(t<Linklimit && flag){

        System.out.println(t);
        at=findAttack(g,k);
        UndirectedGraph gAt=graphAfterAttackWithout(g,at);


        
        
        ArrayList<combins> combinations=getCombinations(gAt);
        UndirectedGraph gTemp=copyGraph(g);
        
        
        int benefitIndex=0;
        int positiveSize=0;
        int i=0;

        gTemp.addEdge(combinations.get(i).s1,combinations.get(i).s2);
        at=findAttack(gTemp,k);
        double vull=findVulnerability(gTemp,at);
        double maxBenefit=vul-vull;
        
        while(i<(combinations.size()-1)){
            i++;
            
            System.out.println(i);
            //gTemp=copyGraph(g);
            gTemp.addEdge(combinations.get(i).s1,combinations.get(i).s2);
            at=findAttack(gTemp,k);
            vull=findVulnerability(gTemp,at);
            if(vul-vull>maxBenefit){
                maxBenefit=vul-vull;
                benefitIndex=i;
            }
            
            Edge e1 = gTemp.getEdge(combinations.get(i).s1, combinations.get(i).s2);
             
            //System.out.println(gTemp.removeEdge(e1));
           
            //gTemp.removeEdge((combinations.get(i).s1,combinations.get(i).s2));
        }
        
        if(maxBenefit<=0)
            flag=false;
        else{
            combins selectedCom=combinations.get(benefitIndex);
            g.addEdge(selectedCom.s1, selectedCom.s2);
            at=findAttack(g,k);
            vul=findVulnerability(g,at);
            ef=findEfficiency(g,at);
            t++;
        
        }
    }

    
            //Gephi initialization
    ProjectController pc2 = Lookup.getDefault().lookup(ProjectController.class);
    pc2.newProject();
    Workspace workspace2 = pc2.getCurrentWorkspace();
    GraphModel graphModel2 = Lookup.getDefault().lookup(GraphController.class).getModel();
    AttributeModel attributeModel2 = Lookup.getDefault().lookup(AttributeController.class).getModel();

	//Get controllers and models
    ImportController importController2 = Lookup.getDefault().lookup(ImportController.class);

    
    Container container2;
        try {
            File file2 = new File("./random100.gml");
            container2 = importController2.importFile(file2);
            container2.getLoader().setEdgeDefault(EdgeDefault.UNDIRECTED);   //Force UNDIRECTED
        } catch (Exception ex) {
            ex.printStackTrace();
            return;
        }
    
     importController2.process(container2, new DefaultProcessor(), workspace2);
        
        
     UndirectedGraph gr = graphModel2.getUndirectedGraph();
    
//   FileWriter writer = new FileWriter("./results.csv");  
   List<Double> efBefore=new ArrayList<>(); 
   List<Double> efAfter=new ArrayList<>(); 
   List<Double> efRand=new ArrayList<>();
   ArrayList<Node> atr;
   
    for(int u=0;u<attackSeq.size();u++){   

        at0=findAttack(g0,attackSeq.get(u));
        efBefore.add(findEfficiency(g0,at0));
  
        
        at=findAttack(g,attackSeq.get(u));
        efAfter.add(findEfficiency(g,at));

        atr=findAttack(gr,attackSeq.get(u));
        efRand.add(findEfficiency(gr,atr));

    }
    
    System.out.println(efBefore.toString());
    System.out.println(efAfter.toString());
    System.out.println(efRand.toString());
    
  

//    List<String> test = new ArrayList<>();
//    test.add("Word1");
//    test.add("Word2");
//    test.add("Word3");
//    test.add("Word4");
   
    //String collect = efBefore.stream().collect(Collectors.joining(","));
    //System.out.println(collect);

    //writer.write(collect);
    //writer.close();



        
        
//        
//        }
//        for(int i=0;i<combinations.size();i++){
//            gTemp=copyGraph(g);
//            gTemp.addEdge(combinations.get(0).s1,combinations.get(0).s2);
//            at=findAttack(gTemp,k);
//            vull=findVulnerability(gTemp,at);
//            benefit.add(vul-vull);
//            if((vul-vull)>0)
//                positiveSize++;
//        }
//          
//                
//     
//       
//
//        if(positiveSize==0)
//            flag=false;
//        
//
//        else{
//            selectedCom<-combinations[[which(benefit==max(benefit))[1]]]
//            n<-names(selectedCom)
//            g<-g+edge(n[1],n[2])
//            at<-findAttack(g,k)
//            vul<-findVulnerability(g,at)
//            ef<-findEfficiency(g,at)
//            t<-t+1
//
//        }
//    }
//
//        
//        
//        
//        
//        
//        //AttributeTable nodeTable = attributeModel.getNodeTable();
//       
//        
//    /*
//        for (Node node : graph.getNodes()){  
//           // String s=node.getAttributes().getValue("name").toString();
//            System.out.println("Nodes: "+node.getAttributes().getValue("name") );
//            System.out.println("Nodes: "+graph.getDegree(node));
//        
//
//	}
//        
//  
//
//        Node[] a=graph.getNodes().toArray();
//        System.out.println("Nodeshghghghghghghjfghfj: "+ a[1].getAttributes().getValue("name"));
//       
//        
//	System.out.println("Nodes: " );
//	System.out.println("Edges: " + graph.getEdgeCount());
//      */
//    System.out.println("Nodes: "+findEfficiency(graph,findAttack(graph,5)) );
//    findAttack(graph,5);
//    
//    //GraphDistance graphDistance = new GraphDistance();
//    
//    //graphDistance.execute(graph.getGraphModel(),attributeModel);
//   
//   // for(EntrySet i : ds.getDistances().entrySet()){
//        
//  // }
//    
//   
//    
//     graph.removeNode(graph.getNode(1));
//     
//    //graphDistance.execute(graph.getGraphModel(),attributeModel);
//    
//    
//        System.out.println("before"+graphAfterAttackWithout(graph,findAttack(graph,5)).getNodeCount());
//        System.out.println("after"+graph.getNodeCount());
//
//       // findAttack(graph,5)  ; 
//       //int l=graph.getNodeCount();
//       ArrayList<String> t=getNodeLabels(graph);
//               //new ArrayList<>();
//       //Node[] nm= new Node[](graph.getNodes().toArray());
//            //for(String e :t ){
//       //     System.out.println(e);
//       //}
//       
//       //while(graph.getNodes().iterator().hasNext())
//       //     System.out.print(t.add(graph.getNodes().iterator().next().getNodeData().getLabel().toString()));
//                  //next().getNodeData().getLabel()
//       
//       
////       t[0]="a";
////       t[1]="b";
////       t[2]="c";
////       for(int i=0;i<t.size();i++){
////          System.out.print(getCombinations(t).get(i).s1);
////          System.out.print(getCombinations(t).get(i).s2.toString());
////          System.out.println();
////       }
////       System.out.println(t.size());
////       System.out.println(getCombinations(t).size());
    }
    
   
     public static ArrayList<Node> findAttack(UndirectedGraph g,int k){
        
        ArrayList<Node> a= new ArrayList<>();
        
        if(k!=0){
            Node[] nodeArray= g.getNodes().toArray();
            
            ArrayList<Integer> degreeArray= new ArrayList<>();
            for (Node nodeArray1 : nodeArray) {
                degreeArray.add(g.getDegree(nodeArray1));
            }
            
            Integer[] maxes=getTopKIndex(degreeArray,k);

             for(int i=0;i<k;i++)
                a.add(nodeArray[maxes[i]]);
        }
     
        return a;
    }
     
     
     public static double findEfficiency(UndirectedGraph g, ArrayList<Node> at){
        GraphView newView = g.getGraphModel().newView();     //Duplicate main view
        UndirectedGraph gtemp = g.getGraphModel().getUndirectedGraph(newView);
        
        gtemp=graphAfterAttackWith(gtemp,at);
        double s=0;
        for(Node n: gtemp.getNodes()){
            double e=0;
            String l=n.getNodeData().getLabel();
            DijkstraShortestPathAlgorithm ds=new DijkstraShortestPathAlgorithm(gtemp,gtemp.getNode(l));
            ds.compute();
            
            for (Map.Entry<NodeData, Double> entry : ds.getDistances().entrySet())
                if(entry.getValue()!=0)
                    e=e+(1/entry.getValue());
            s=s+e; 
        }
    
        return s/(gtemp.getNodeCount()*(gtemp.getNodeCount()-1));

    }
     
     
    public static double findVulnerability(UndirectedGraph g, ArrayList<Node> at){
        GraphView newView = g.getGraphModel().newView();     //Duplicate main view
        UndirectedGraph gtemp = g.getGraphModel().getUndirectedGraph(newView);
        
        ArrayList<Node> at2=new ArrayList<>();
        if(findEfficiency(gtemp,at2)!=0)
            return (1-(findEfficiency(g,at)/findEfficiency(g,at2)));
        else 
            return 0;
       
    }
     
   
    public static UndirectedGraph copyGraph(UndirectedGraph g){
        GraphView newView = g.getGraphModel().newView();     //Duplicate main view
        UndirectedGraph gtemp = g.getGraphModel().getUndirectedGraph(newView);
        return gtemp;
    
    }
     
     public static UndirectedGraph graphAfterAttackWithout(UndirectedGraph g,ArrayList<Node> at){
         
        
        UndirectedGraph gtemp = copyGraph(g);


        if(at.isEmpty())
            return gtemp;
        else
            for(int i=0;i<at.size();i++)
                gtemp.removeNode(at.get(i));
        
        return gtemp;
    } 
     
      public static UndirectedGraph graphAfterAttackWith(UndirectedGraph g,ArrayList<Node> at){
         
         
        GraphView newView = g.getGraphModel().newView();     //Duplicate main view
        UndirectedGraph gtemp = g.getGraphModel().getUndirectedGraph(newView);


        if(at.isEmpty())
            return gtemp;
        else
            for(int i=0;i<at.size();i++){
                gtemp.removeNode(at.get(i));
                gtemp.addNode(at.get(i));
            }
        return gtemp;
    } 
     
  
    public static Integer[] getTopKIndex(ArrayList<Integer> a,int k){
        ArrayIndexComparator comparatorr = new ArrayIndexComparator(a);
        Integer[] indexes = comparatorr.createIndexArray();
        Arrays.sort(indexes, comparatorr);       
        return  indexes;
    }
    
    public static ArrayList<Node> getNodeArrayList(UndirectedGraph g){
        ArrayList<Node> s=new ArrayList<>();
        Node[] nm=g.getNodes().toArray();
        s.addAll(Arrays.asList(nm));
        return  s;
    }
    
    public static ArrayList<combins> getCombinations(UndirectedGraph g){
        
        ArrayList<Node> s=getNodeArrayList(g);
        int l=s.size();
        ArrayList<combins> c=new ArrayList<>();
        for(int i=0;i<(l-1);i++){
            for(int j=i+1;j<l;j++){
               
                c.add(new combins(s.get(i),s.get(j)));
            }
        }
        return  c;
    }
    
    public static ArrayList<String> getNodeLabels(UndirectedGraph g){
        
        ArrayList<String> t=new ArrayList();
        Node[] nm=g.getNodes().toArray();
        for(Node n :nm ){
            t.add(n.getNodeData().getLabel());
        }
        return t;
    }
    
}
