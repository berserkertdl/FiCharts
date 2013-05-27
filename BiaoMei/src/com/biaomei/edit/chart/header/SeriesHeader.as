package com.biaomei.edit.chart.header
{
	import com.fiCharts.utils.ClassUtil;
	import com.fiCharts.utils.XMLConfigKit.XMLVOMapper;
	import com.fiCharts.utils.XMLConfigKit.style.IStyleStatesUI;
	import com.fiCharts.utils.XMLConfigKit.style.States;
	import com.fiCharts.utils.XMLConfigKit.style.StatesControl;
	import com.fiCharts.utils.XMLConfigKit.style.Style;
	import com.fiCharts.utils.graphic.BitmapUtil;
	import com.fiCharts.utils.graphic.StyleManager;
	import com.greensock.TweenLite;
	
	import ui.IconBtn;
	import ui.LabelInput;
	import ui.LabelInputEvent;
	import com.biaomei.edit.chart.SeriesHeaderEvt;
	import com.biaomei.edit.chart.SeriesProxy;
	import com.biaomei.edit.chartTypeBox.ChartTypePanel;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 */	
	public class SeriesHeader extends Sprite implements IStyleStatesUI
	{
		public function SeriesHeader(series:SeriesProxy)
		{
			super();
			
			this.series = series;
			
			del_over;
			del_out;
			
			XMLVOMapper.fuck(statesXML, states);
			this.statesControl = new StatesControl(this, this.states);
				
			addChild(headTop);
			addChild(headBottom);
			headTop.addEventListener(MouseEvent.MOUSE_UP, headerClickHandler, false, 0, true);	
		}
		
		/**
		 * 
		 */		
		public var ifOver:Boolean = false;
		

		/**
		 */		
		private function headerClickHandler(evt:MouseEvent):void
		{
			if (ifSelected == false)
			{
				var hEvt:SeriesHeaderEvt = new SeriesHeaderEvt(SeriesHeaderEvt.HEADER_SELECT);
				hEvt.header = this;
				this.dispatchEvent(hEvt);
			}
		}
		
		/**
		 */		
		private var statesControl:StatesControl;
		
		/**
		 */		
		public function open():void
		{
			if (ifSelected == false)
			{
				statesControl.toDown();
				this.statesControl.enable = false;
				headBottom.alpha = 0;
				TweenLite.to(headBottom, 0.3, {alpha: 1});
				headBottom.visible = true;
				
				this.nameTxtField.setFocus();
				headTop.isInteractive = false;
				ifSelected = true;
			}
		}
		
		/**
		 */		
		public function close():void
		{
			if (ifSelected)
			{
				statesControl.toNormal();
				statesControl.enable = true;
				
				//nameTxtField.leave();
				//headBottom.mouseChildren = headBottom.mouseEnabled = false;
				TweenLite.to(headBottom, 0.3, {alpha: 0, onComplete:closed});
				headTop.isInteractive = true;
				ifSelected = false;
			}
		}
		
		/**
		 */		
		private function closed():void
		{
			headBottom.visible = false;
		}
		
		/**
		 */		
		public var ifSelected:Boolean = false;
		
		/**
		 */		
		private function labelShowed():void
		{
			headBottom.mouseChildren = headBottom.mouseEnabled = true;
		}
		
		/**
		 */		
		public function get states():States
		{
			return _states;
		}
		
		/**
		 */		
		private var _states:States = new States;
		
		public function set states(value:States):void
		{
			_states = value;
		}
		
		/**
		 */		
		private var statesXML:XML = <states>
										<normal>
											<border color="EEEEEE" alpha="0"/>
											<fill color='#DDDDDD' alpha='0.2'/>
										</normal>
										<hover>
											<border color="EEEEEE" alpha="0"/>
											<fill color='#2494E6' alpha='0.1' angle="90"/>
										</hover>
										<down>
											<border color="EEEEEE" alpha="0"/>
											<fill color='#2494E6' alpha='0.2' angle="90"/>
										</down>
									</states>
		
		/**
		 */		
		public function get currState():Style
		{
			return _style;
		}
		
		/**
		 */		
		public function set currState(value:Style):void
		{
			_style = value;
		}
		
		/**
		 */		
		private var _style:Style;
		
		/**
		 */		
		public function hoverHandler():void
		{
			
		}
		
		/**
		 */		
		public function normalHandler():void
		{
			
		}
		
		/**
		 */		
		public function downHandler():void
		{
			
		}
		
		/**
		 */		
		private function nameFieldLeaveHandler(evt:Event):void
		{
			this.close();
		}
		
		/**
		 */		
		public function render():void
		{
			if (ifReady == false)
			{
				initTopHeader();
				initLabelField();
				
				chartBmd = ClassUtil.getObjectByClassPath(ChartTypePanel.getChartBitmapByType(series.type)) as BitmapData;
				ifReady = true;
			}
			
			headTop.graphics.clear();
			this.currState.tx = 1;
			this.currState.ty = 0;
			currState.width = series.headWidth - 2;
			currState.height = series.headHeight;
			StyleManager.drawRect(headTop, currState);
			
			headTop.graphics.beginFill(0x2494E6, 0.8);
			headTop.graphics.drawRect(1, series.headHeight - 3,  series.headWidth - 2, 3);
			headTop.graphics.endFill();
			
			var imgSize:uint = 25;
			var ifSmooth:Boolean = false;
			
			// 不同图表类型有圆有方，绘制方式不同
			if (series.type == ChartTypePanel.BUBBLE || series.type == ChartTypePanel.PIE || 
				series.type == ChartTypePanel.AREA || series.type == ChartTypePanel.LINE)
			{
				
				ifSmooth = true;
			}
			
			BitmapUtil.drawBitmapDataToSprite(chartBmd, headTop, imgSize, imgSize, 
				8, series.headHeight - imgSize - 5, ifSmooth);
		}
		
		/**
		 */		
		private var ifReady:Boolean = false;
		
		/**
		 */		
		private function initTopHeader():void
		{
			delBtn.init("del_out", 'del_over', 'del_out', 14, 14);
			delBtn.render();
			delBtn.x = (series.headWidth - delBtn.width - 5);
			delBtn.y = 5//(series.headHeight - delBtn.height)// / 2;
			delBtn.tips = "删除图表，保留数据"
			delBtn.addEventListener(MouseEvent.CLICK, series.deleteThisHandler, false, 0, true);
			this.addChild(delBtn);
		}
		
		/**
		 */		
		private var chartBmd:BitmapData 
		
		/**
		 */		
		protected function initLabelField():void
		{
			nameTxtField.defaultStyleXML = nameTxtField.selectStyleXML = <style>
																			<border alpha='0'/>
																			<fill alpha='0'/>
																		</style>;
			nameTxtField.setTextFormat(12, 'FFFFFF');
			nameTxtField.defaultTxt = ""//series.name;
			nameTxtField.w = series.headWidth - 15;
			nameTxtField.ifWordwrap = true;
			nameTxtField.ifBreakLine = false;
			nameTxtField.addEventListener(Event.RESIZE, resizeTxtField, false, 0, true);
			nameTxtField.addEventListener(Event.CHANGE, txtFieldChanged, false, 0, true);
			nameTxtField.addEventListener(LabelInputEvent.ENTER_LEAVE, nameFieldLeaveHandler, false, 0, true);
			nameTxtField.render();
			
			nameTxtField.x = 3;
			nameTxtField.y = 3;
			
			drawNameFieldBG();
			
			headBottom.visible = false;
			headBottom.y = 0;
			headBottom.addChild(nameTxtField);
			//headBottom.mouseChildren = headBottom.mouseEnabled = false;
		}
		
		/**
		 */		
		public function ready():void
		{
//			/headBottom.height = h;	
			
			if (series.ifRename)
			{
				this.nameTxtField.text = series.name;
				series.ifRename = false;
			}
		}
		
		/**
		 */		
		private function resizeTxtField(evt:Event):void
		{
			drawNameFieldBG();
		}
		
		/**
		 */		
		private function drawNameFieldBG():void
		{
			var fillH:Number = nameTxtField.h + 5;
			
			if (fillH < series.headHeight)
				fillH = series.headHeight;
			
			//绘制背景
			headBottom.graphics.clear();
			headBottom.graphics.beginFill(0x2494E6, 0.9);
			headBottom.graphics.drawRect(1, 0,  series.headWidth - 2, fillH);
			headBottom.graphics.endFill();
		}
		
		/**
		 */		
		private function txtFieldChanged(evt:Event):void
		{
			series.name = nameTxtField.text;
		}
		
		/**
		 */		
		private var series:SeriesProxy;
		
		/**
		 */		
		private var delBtn:IconBtn = new IconBtn;
		
		/**
		 */		
		private var nameTxtField:LabelInput = new LabelInput;
		
		/**
		 */		
		private var headTop:HeaderTop = new HeaderTop;
		
		/**
		 */		
		private var headBottom:Sprite = new Sprite;
	}
}