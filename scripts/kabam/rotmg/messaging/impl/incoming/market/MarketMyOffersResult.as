package kabam.rotmg.messaging.impl.incoming.market
{
   import com.company.assembleegameclient.util.FreeList;
   import flash.utils.IDataInput;
   import kabam.rotmg.messaging.impl.data.MarketData;
   import kabam.rotmg.messaging.impl.incoming.IncomingMessage;
   
   public class MarketMyOffersResult extends IncomingMessage
   {
       
      
      public var results_:Vector.<MarketData>;
      
      public function MarketMyOffersResult(param1:uint, param2:Function)
      {
         this.results_ = new Vector.<MarketData>();
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = param1.readShort();
         _loc2_ = _loc3_;
         while(_loc2_ < this.results_.length)
         {
            FreeList.deleteObject(this.results_[_loc2_]);
            _loc2_++;
         }
         this.results_.length = Math.min(_loc3_,this.results_.length);
         while(this.results_.length < _loc3_)
         {
            this.results_.push(FreeList.newObject(MarketData) as MarketData);
         }
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            this.results_[_loc2_].parseFromInput(param1);
            _loc2_++;
         }
      }
   }
}
