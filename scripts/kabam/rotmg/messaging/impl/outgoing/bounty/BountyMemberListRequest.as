package kabam.rotmg.messaging.impl.outgoing.bounty
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   
   public class BountyMemberListRequest extends OutgoingMessage
   {
       
      
      public function BountyMemberListRequest(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
      }
      
      override public function toString() : String
      {
         return formatToString("BOUNTYMEMBERLISTREQUEST");
      }
   }
}
