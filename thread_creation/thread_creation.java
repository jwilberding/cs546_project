

public class thread_creation implements Runnable
{
   public static void main(String args[]) throws Throwable
   {
      for (int i=0;i<10000;i++)
      {
        thread_creation tc = new thread_creation ();
        new Thread(tc).start();
      }
   }

   public void run()
   {
      try {
        // nothing
      } catch (Throwable t) { }
   }
}
