package kabam.rotmg.messaging.impl.outgoing.party
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.outgoing.OutgoingMessage;
   
   public class JoinParty extends OutgoingMessage
   {
       
      
      public var leader_:String;
      
      public var partyId:int;
      
      public function JoinParty(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeUTF(this.leader_);
         param1.writeInt(this.partyId);
      }
      
      override public function toString() : String
      {
         return formatToString("JOINGUILD","guildName_");
      }
   }
}
