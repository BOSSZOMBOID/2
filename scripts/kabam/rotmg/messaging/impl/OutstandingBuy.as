package kabam.rotmg.messaging.impl
{
   class OutstandingBuy
   {
       
      
      private var id_:String;
      
      private var price_:int;
      
      private var currency_:int;
      
      function OutstandingBuy(param1:String, param2:int, param3:int)
      {
         super();
         this.id_ = param1;
         this.price_ = param2;
         this.currency_ = param3;
      }
   }
}
