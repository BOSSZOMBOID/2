package kabam.rotmg.messaging.impl.incoming.bounty
{
   import flash.utils.IDataInput;
   import kabam.rotmg.messaging.impl.incoming.IncomingMessage;
   
   public class BountyMemberListSend extends IncomingMessage
   {
       
      
      public var playerIds:Vector.<int>;
      
      public function BountyMemberListSend(param1:uint, param2:Function)
      {
         this.playerIds = new Vector.<int>();
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.playerIds.length = 0;
         var _loc2_:int = param1.readInt();
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_)
         {
            this.playerIds.push(param1.readInt());
            _loc3_++;
         }
      }
   }
}
