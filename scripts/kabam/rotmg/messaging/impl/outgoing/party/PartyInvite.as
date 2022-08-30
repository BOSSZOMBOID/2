package kabam.rotmg.messaging.impl.outgoing.party
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   
   public class PartyInvite extends OutgoingMessage
   {
       
      
      public var name_:String;
      
      public function PartyInvite(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeUTF(this.name_);
      }
      
      override public function toString() : String
      {
         return formatToString("PARTY_INVITE","name_");
      }
   }
}
