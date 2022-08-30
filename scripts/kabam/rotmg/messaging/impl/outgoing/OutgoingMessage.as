package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataInput;
   import kabam.lib.net.impl.Message;
   
   public class OutgoingMessage extends Message
   {
       
      
      public function OutgoingMessage(param1:uint, param2:Function, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
      
      override public final function parseFromInput(param1:IDataInput) : void
      {
         throw new Error("Client should not receive " + id + " messages");
      }
   }
}
