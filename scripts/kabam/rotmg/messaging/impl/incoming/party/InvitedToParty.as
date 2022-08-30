package kabam.rotmg.messaging.impl.incoming.party
{
   import flash.utils.IDataInput;
   import kabam.rotmg.messaging.impl.incoming.IncomingMessage;
   
   public class InvitedToParty extends IncomingMessage
   {
       
      
      public var name_:String;
      
      public var partyId_:int;
      
      public function InvitedToParty(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.name_ = param1.readUTF();
         this.partyId_ = param1.readInt();
      }
      
      override public function toString() : String
      {
         return formatToString("INVITED_TO_PARTY","name_");
      }
   }
}
