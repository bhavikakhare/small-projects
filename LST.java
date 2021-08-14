
/* 
 * LST ( DPV 5.23 ) by BHAVIKA KHARE (U00786341) as part of COMP-7712 PA-2
 * 
 * PROBLEM
 * This is an implementation of the LEAST SPANNING TREE problem given in the textbook ( DPV #5.23 )
 * Given an undirected graph G = (V,E) & edge weights w[] & a subset(U) of all vertices(V) of G
 * This program outputs the lightest spanning tree in which the nodes of U are leaves 
 * There might be other leaves in this tree as well
 * 
 * SOLUTION
 * This is accomplished in O(E*logV) time
 * First choose the lightest edge going to (V-U) for each node u in set U		= O(E)
 * Add this set of nodes to the MST of graph G						= O(E*logV)
 * We find the MST using PRIM's ALGORITHM for MSTs					-----------
 * Total time complexity								= O(E*logV)			
 * 		
 */

import java.util.*;

public class LST {
	
	static class EdgeComparator implements Comparator<Edge> {
	    public int compare( Edge e1 , Edge e2 ) {
	        if( e1.w == e2.w ) return 0 ;
	        else if( e1.w >= e2.w ) return 1 ;
	        else return -1 ;
	    }
	}
	
	static class Edge {
		int to = 0 ;
		int from = 0 ;
		float w = 0 ;
		Edge( int to , int from , float weight ) {
			this.to = to ; 		// destination node
			this.from = from ;	// current node or source node
			this.w = weight ;
		}
	}
	
	static class Graph {

		Map<Integer,List<Edge>> map = new HashMap<>() ;
		List<Boolean> U ;	// tells whether or not a node lies in U 
		
		void nodes( int n ) {
			for( int i=1 ; i<=n ; i++ )
				map.put( i , new LinkedList<Edge>() );
			U = new ArrayList<Boolean>() ;
			for( int i=0 ; i<=n ; i++ ) 
				U.add(false) ;
		}
		
		void addEdge( int to , int from , float weight ) {
			map.get( to ).add( new Edge( from , to , weight ) ) ;
			map.get( from ).add( new Edge( to , from , weight ) ) ;
		}
		
		List<Edge> MST() {	
			
			// PRIM'S MST ALGORITHM		

			// declare queues & lists & pointers
			
			Edge mst_edge ;
			List<Edge> x = new ArrayList<>() ;
			Comparator<Edge> cmp = new EdgeComparator() ;
			PriorityQueue<Edge> pq = new PriorityQueue<>(10, cmp );
			List<Boolean> V = new ArrayList<>() ;
			for( int i=0 ; i<U.size() ; i++ )
				V.add(false) ;
			
			// find a node to start the MST with
			
			int count = 1 ;
			 Map.Entry<Integer,List<Edge>> n = map.entrySet().iterator().next();
			 int node = n.getKey() ;
			 
			 // PRIM'S MST ALGORITHM
			 // choose (map.size-1) edges for the MST 
			 
			 while( count++<map.size() ) {
				 V.set( node , true ) ;
				 for( Edge e : map.get( node ) )
					 pq.add(e) ;
				 do {
					 mst_edge = pq.poll() ;
				 } while ( U.get( mst_edge.to ) || V.get( mst_edge.to ) ) ;
				 x.add( mst_edge ) ;
				 node = mst_edge.to ;
			 }
			 
			return x ;
			
		}
		
		List<Edge> LeastST() {
			List<Edge> LSTset = new ArrayList<>() ;
			// the minimum edge from each node in U to V-U is chosen
			for( int i=1 ; i<U.size() ; i++ ) {
				if( U.get(i) ) {
					float min = Float.MAX_VALUE ;
					Edge min_e = new Edge(0,0,min);
					for( int j=0 ; j<map.get(i).size() ; j++ ) {
						Edge e = map.get(i).get(j) ;
						if( !U.get(e.to) && e.w<min ) { 
							min = e.w ; 
							min_e = e ;
						}
					}
					LSTset.add(min_e) ;
					// remove the node i from the map to leave just V-U in G for the call to MST()
					map.remove(i) ;
				}
			}
			// connect inner MST(G-U) to leaf nodes U using edges in [LSTset]
			LSTset.addAll( MST() ) ;
			printLST( LSTset ) ;
			return LSTset ;
		}
		
		void printLST( List<Edge> x ) {
			String s = "The edges are : " ;
			float w = 0 ;
			for( int i=0 ; i<x.size() ; i++ ) {
				Edge e = x.get(i) ;
				w+=e.w ;
				s+="("+e.to+","+e.from+")" ;
				if(i<x.size()-1) s+=", " ;
			}
			System.out.println(s) ;
			System.out.println( "The weight is : "+w ) ;
		}
		
		void getMAP() {
			Scanner s = new Scanner(System.in) ;
			nodes( s.nextInt() ) ;
			int e = s.nextInt() ;
			while( e-->0 ) 
				addEdge( s.nextInt() , s.nextInt() , s.nextFloat() ) ;
//			nicer code but it does not work as well
//			while( s.hasNextInt() ) 
//				U.set( s.nextInt() , true ) ;
			s.nextLine();
			String u_string = s.nextLine() ;
			List<Integer> u_list = new ArrayList<Integer>() ;
			for( String t : u_string.split(" ")) {
				u_list.add( Integer.parseInt(t) ) ;
			}
			for( int i : u_list ) U.set( i , true ) ;
			s.close() ;
		}
		
	}

	public static void main( String[] s ) {
		Graph g = new Graph() ;
		g.getMAP() ;
		g.LeastST() ; 
	}

}
