package kabam.rotmg.messaging.impl.outgoing.bounty
{
   import flash.utils.IDataOutput;
   import kabam.rotmg.messaging.impl.outgoing.*;
   
   public class BountyRequest extends OutgoingMessage
   {
       
      
      public var BountyId:int;
      
      public var playersAllowed:Vector.<int>;
      
      public function BountyRequest(param1:uint, param2:Function)
      {
         super(param1,param2);
         this.playersAllowed = new Vector.<int>();
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.BountyId);
         param1.writeInt(this.playersAllowed.length);
         var _loc2_:int = 0;
         while(_loc2_ < this.playersAllowed.length)
         {
            param1.writeInt(this.playersAllowed[_loc2_]);
            _loc2_++;
         }
      }
      
      override public function toString() : String
      {
         return formatToString("BOUNTYREQUEST","BountyId","playersAllowed");
      }
   }
}
