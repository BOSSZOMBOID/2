package kabam.rotmg.messaging.impl.data
{
   import flash.utils.IDataInput;
   
   public class TalismanData
   {
       
      
      public var type_:int;
      
      public var level_:int;
      
      public var xp_:int;
      
      public var goal_:int;
      
      public var tier_:int;
      
      public var active_:Boolean;
      
      public function TalismanData()
      {
         super();
      }
      
      public function parseFromInput(param1:IDataInput) : void
      {
         this.type_ = param1.readByte();
         this.level_ = param1.readByte();
         this.xp_ = param1.readInt();
         this.goal_ = param1.readInt();
         this.tier_ = param1.readByte();
         this.active_ = param1.readBoolean();
      }
      
      public function toString() : String
      {
         return "Todo: Print Something If needed";
      }
   }
}
