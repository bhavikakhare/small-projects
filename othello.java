/*******************
 * Main function that we are using internally -  

final static int player1Symbol = 1;
final static int player2Symbol = 2;

public static void main(String[] args) {
	OthelloBoard b = new OthelloBoard();
	int n = s.nextInt();
	boolean p1Turn = true;
	while(n > 0) {
		int x = s.nextInt();
		int y = s.nextInt();
		boolean ans = false;
		if(p1Turn) {
			ans = b.move(player1Symbol, x, y);
		}
		else {
			ans = b.move(player2Symbol, x, y);
		}
		if(ans) {
			b.print();
			p1Turn = !p1Turn;
			n--;
		}
		else {
			System.out.println(ans);
		}
	}
}
*****************/

public class OthelloBoard {

	private int board[][];
	final static int player1Symbol = 1;
	final static int player2Symbol = 2;

	public OthelloBoard() {
		board = new int[8][8];
		board[3][3] = player1Symbol;
		board[3][4] = player2Symbol;
		board[4][3] = player2Symbol;
		board[4][4] = player1Symbol;
	}

	public void print() {
		for(int i = 0; i < 8; i++) {
			for(int j = 0; j < 8; j++) {
				System.out.print(board[i][j] + " ");
			}
			System.out.println();
		}
	}

	public boolean move(int symbol, int x, int y){
		// Complete this function
		/* Don't write main().
		 * Don't read input, it is passed as function argument.
		 * Return output and don't print it.
		 * Taking input and printing output is handled automatically.
		 */
      if(x>=8||y>=8) return false;
      if(board[x][y]!=0) return false;
      boolean r=false;
      int s2=1; if(symbol==1) s2=2;
      int[] X=new int[]{-1,-1,-1,0,0,1,1,1};
      int[] Y=new int[]{1,0,-1,1,-1,1,0,-1};
      
      for(int i=0;i<8;i++) {
        int cx=x+X[i],c2x=cx+X[i],cy=y+Y[i],c2y=cy+Y[i];
        //if(c2x>=0&&c2x<8&&c2y>=0&&c2y<8) {
         /* if(board[c2x][c2y]==symbol&&board[cx][cy]==s2) {
            r=true;
            board[x][y]=symbol;
            board[cx][cy]=symbol;
            move(symbol,cx,cy);
          } */
          while(c2x>=0&&c2y>=0&&c2x<8&&c2y<8&&board[cx][cy]==s2) {
            cx+=X[i];c2x+=X[i];
            cy+=Y[i];c2y+=Y[i];
          } cx-=X[i];c2x-=X[i]; cy-=Y[i];c2y-=Y[i];
        
        /* At this point, say player1 is playing, if a 12221 pattern is possible in some 
        direction, (cx,cy) will point to the last 2, and if no 2 i found, i.e., 11 pattern
        ( = invalid move ) is possible in one direction, (cx,cy) points to the (x,y) itself. */
        
          if((cx!=x||cy!=y)&&board[c2x][c2y]==symbol) {
            r=true;
            while(cx!=x||cy!=y) {
              board[cx][cy]=symbol;
              /* turns all 2s between two 1s into 1s */
              //move(symbol,cx,cy);
              /* checks if these new 1s will cause other moves to become possible */
              // according to one website this^^^ is not needed so I commented the recursive call
              cx-=X[i]; cy-=Y[i];
            } board[x][y]=symbol;
          }
        //} //remove ifs
      }
		return r;
	}
}
