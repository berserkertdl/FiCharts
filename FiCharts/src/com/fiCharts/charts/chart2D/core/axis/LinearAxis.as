package com.fiCharts.charts.chart2D.core.axis
{
	import com.fiCharts.charts.chart2D.core.events.DataResizeEvent;
	import com.fiCharts.charts.chart2D.core.model.SeriesDataFeature;
	import com.fiCharts.utils.XMLConfigKit.XMLVOMapper;

	/**
	 * 
	 * 线性坐标轴，数据线性分布，坐标位置根据数据线性关系分布
	 * 
	 */	
	public class LinearAxis extends AxisBase
	{
		/**
		 * Constructor.
		 */
		public function LinearAxis()
		{
			super();
		}
		
		
		/**
		 */		
		override public function resizeData(start:Number, end:Number):void
		{
			var min:Number, max:Number;
			min = start * this.sourceValueDis;
			max = end * sourceValueDis;
			
			// 确定当前最值
			this.preMaxMin(max, min);
			this.confirmMaxMin();
			
			currentDataRange.min = this.minimum;
			currentDataRange.max = this.maximum;
			
			// 
			setFullSizeAndOffsize();
			this.setCurrentLabelsIndexRange();
			
			changed = true;
			
			this.dispatchEvent(new DataResizeEvent(DataResizeEvent.RESIZE_BY_RANGE, 
				this.currentDataRange.min, currentDataRange.max));
		}
		
		
		/**
		 */		
		override public function getXLabel(value:Object):String
		{
			return dataFormatter.formatXNumber(value);
		}
		
		override public function getYLabel(value:Object):String
		{
			return dataFormatter.formatYNumber(value);
		}
		
		override public function getZLabel(value:Object):String
		{
			return dataFormatter.formatZNumber(value);
		}
		
		/**
		 * Push the values of axis and count the maxValue/minValue
		 * @param values
		 */
		override public function pushValues(values:Vector.<Object>):void
		{
			sourceValues = sourceValues.concat(values);
		}
		
		/**
		 */		
		override public function getSeriesDataFeature(seriesData:Vector.<Object>):SeriesDataFeature
		{
			var seriesDataFeature:SeriesDataFeature = new SeriesDataFeature;
			
			seriesData.sort(Array.NUMERIC);
			
			// 单值的情况；
			if (seriesData.length == 1)
			{
				seriesDataFeature.maxValue = seriesDataFeature.minValue = seriesData.pop();
			}
			else // 多值的情况
			{
				seriesDataFeature.minValue = seriesData.shift();
				seriesDataFeature.maxValue = seriesData.pop();
			}
			
			return seriesDataFeature;
		}
		
		/**
		 * 坐标轴是否自动调节最大值与最小值， 默认开启；
		 */		
		private var _autoAdjust:Boolean = true;

		/**
		 */
		public function get autoAdjust():Boolean
		{
			return _autoAdjust;
		}

		/**
		 * @private
		 */
		public function set autoAdjust(value:Boolean):void
		{
			_autoAdjust = value;
		}

		/**
		 * 确定最大最小值；
		 */		
		override public function dataUpdated():void
		{
			sourceValues.sort(Array.NUMERIC);
			
			if (!isNaN(assignedMinimum))
				sourceMin = assignedMinimum;
			else
				sourceMin = Number(sourceValues[0]);
			
			if (!isNaN(assignedMaximum))
				sourceMax = assignedMaximum;
			else
				sourceMax = Number(sourceValues[sourceValues.length - 1]);
			
			// 单值的情况；
			if (sourceValues.length == 1)
				sourceMin = sourceMax = Number(sourceValues[0]);
			
			if (autoAdjust == false)
			{
				_maximum = sourceMax;
				_minimum = sourceMin;
					
				this.changed = false;
				return; 
			}
			
			//基于零点优先于最值设置；
			if (baseAtZero && sourceMin * sourceMax >= 0)
			{
				if (sourceMax > 0)
					sourceMin = 0;
				else if (sourceMax < 0)
					sourceMax = 0;
			}
			
			sourceValueDis = sourceMax - sourceMin;
			preMaxMin(sourceMax, sourceMin);
			
			super.dataUpdated();
		}
		
		/**
		 */		
		protected var sourceValueDis:Number;
		
		/**
		 * 正式渲染之前调用; 子数据范围渲染前不调用此方法
		 */		
		override public function beforeRender():void
		{
			if (changed)
			{
				confirmMaxMin();
				
				currentDataRange.min = sourceDataRange.min = this.minimum;
				currentDataRange.max = sourceDataRange.max = this.maximum;
				
				//获得最值差，供后继频繁计算用
				confirmedSourceValueRange = sourceDataRange.max - sourceDataRange.min;
				
				setFullSizeAndOffsize();
				
				this.createLabelsData();
				setCurrentLabelsIndexRange();
			}
		}
		
		/**
		 */		
		private function setFullSizeAndOffsize():void
		{
			fullSize = this.size / (currentDataRange.max - currentDataRange.min) * confirmedSourceValueRange;
			this.offsetSize = (currentDataRange.min - sourceDataRange.min) / confirmedSourceValueRange * fullSize;
		}
		
		/**
		 * 与判定最大最小值
		 */		
		private function preMaxMin(max:Number, min:Number):void
		{
			var preDataDis:Number = max - min;
			var powerOfTen:Number = Math.floor(Math.log(Math.abs(preDataDis)) / Math.LN10);
			var y_userInterval:Number;
			
			if (isNaN(_userInterval))
			{
				y_userInterval = Math.pow(10, powerOfTen);
				
				if (Math.abs(preDataDis) / y_userInterval < 4)
				{
					y_userInterval = y_userInterval / 5;
				}
			}
			else
			{
				y_userInterval = _userInterval;
			}
			
			_maximum = preMax = Math.round(max / y_userInterval) * y_userInterval == max ? max : (Math.floor(max / y_userInterval) + 1) * y_userInterval;
			_minimum = preMin = Math.floor(min / y_userInterval) * y_userInterval;
			
			preInterval = y_userInterval;
		}
		
		/**
		 * 核定，确定最大最小值
		 */		
		private function confirmMaxMin():void
		{
			var preValueDis:Number = preMax - preMin;
			
			//最小单位值
			var minUintValue:Number = 0;
			if (horiMinUintSize <= size)
				minUintValue = Math.max(horiMinUintSize / size * preValueDis, preValueDis / maxDepartLineAmount);
			else
				minUintValue = preValueDis;
			
			var internalAmount:Number = preValueDis / this.preInterval;
			for (var amoutInternal:uint = 1; amoutInternal <= internalAmount; amoutInternal++)
			{
				interval = preInterval * amoutInternal;
				if (interval >= minUintValue && interval <= preValueDis)
					break;
			}
			
			// 调节恰到好处的最值，刚好满足均分 
			if (preMin * preMax < 0)
			{
				_maximum = preMin + Math.ceil(preValueDis/ interval) * interval;
				
				if (ifExpend)
				{
					_maximum += interval;
					_minimum = preMin - interval;
				}
				/*else
				{
				_maximum += interval / 2;
				_minimum = sourceMin - interval / 2;
				}*/
			}
			else if (preMax > 0)
			{
				_maximum = preMin + Math.ceil(preValueDis/ interval) * interval;
				
				if (ifExpend)
					_maximum += interval;
			}
			else if (preMax == 0)
			{
				//_maximum = sourceMin + Math.ceil((sourceMax -  sourceMin)/ interval) * interval;
				
				_minimum = preMax - Math.ceil(preValueDis/ interval) * interval;
				if (ifExpend)
					_minimum -= interval;
			}
			else 
			{
				_minimum = preMax - Math.ceil(preValueDis/ interval) * interval;
				
				if (ifExpend)
					_minimum -= interval;
			}
			
		}
		
		/**
		 * 生成标签数据，划定显示标签的范围
		 */		
		private function createLabelsData():void
		{
			var labelData:AxisLabelData;
			labelsData = new Vector.<AxisLabelData>;
			
			//// Flash 中数字计算精度有偏差, 防止与最值及其相近的值蒙混过关
			var maxValue:Number = this.sourceDataRange.max + interval - interval / 100000;
			
			// label数据每次重新构建
			for (var i:Number = this.sourceDataRange.min; i < maxValue; i += interval)
			{
				labelData = new AxisLabelData();
				labelData.value = i;
				labelsData.push(labelData);
			}
			
			horiLabelUIs.length = 0;
			this.clearLabels()
		}
		
		/**
		 */		
		private function setCurrentLabelsIndexRange():void
		{
			var length:uint = this.labelsData.length;
			
			labelStartIndex = 0;
			labelEndIndex = length - 1;
			
			for (var i:Number = 0; i < length; i ++)
			{
				if (this.currentDataRange.min >= Number(labelsData[i].value))
				{
					this.labelStartIndex = i;
				}
				else if (currentDataRange.max <= Number(labelsData[i].value))
				{
					this.labelEndIndex = i;
					break;
				}
				else
				{
					continue;
				}
			}
		}
			
		
		/**
		 * 原始值的最大最小值
		 */		
		protected var sourceMax:Number = 0;
		protected var sourceMin:Number = 0;
		
		/**
		 * 违背核定的最值
		 */		
		protected var preMax:Number;
		protected var preMin:Number;
		
		/**
		 * 根据原始值核定后的最大最小值 
		 */		
		private var sourceDataRange:DataRange = new DataRange;
		
		
		/**
		 * 当前的数据范围(被核定后的) 
		 */		
		private var currentDataRange:DataRange = new DataRange;
		
		
		/**
		 * 再启用数值显示的时候需要增多一个数据单元格以便放得下数值显示；
		 */		
		private var _ifExpend:Boolean = false;

		/**
		 */
		public function get ifExpend():Boolean
		{
			return _ifExpend;
		}

		/**
		 * @private
		 */
		public function set ifExpend(value:Boolean):void
		{
			_ifExpend = value;
		}


		/**
		 * temp value
		 */
		protected var assignedMinimum:Number;
		protected var assignedMaximum:Number;

		/**
		 * 最大单元格数量；
		 */
		protected var maxDepartLineAmount:uint = 10;

		/**
		 * 轴步长
		 * (可由用户设置)
		 */
		private var _userInterval:Number;

		public function set userInterval(value:Number):void
		{
			_userInterval = value;
		}

		public function get userInterval():Number
		{
			return _userInterval;
		}
		
		/**
		 *  An opposite value indicate labels distance.
		 *  This value is from o to 1, for example, .1 indicate this axis will contain 10 labels.
		 */
		private var _interval:Number = .2;
		
		public function get interval():Number
		{
			return _interval;
		}
		
		/**
		 */
		public function set interval(v:Number):void
		{
			_interval = v;
		}

		/**
		 * 初步计算得到的步长， 还需根据最小刻度尺寸才能计算出最终的步长  interval
		 */
		protected var preInterval:Number;

		/**
		 *  Axis has it's own data model different from default data value.
		 *  For example, date axis's axis data format is Number,
		 *  but it's data value is String like '2009-01-01'.
		 */
		protected function axisValueToX(value:Object):Number
		{
			return axisValueToSize(value);
		}

		protected function axisValueToY(value:Object):Number
		{
			return - axisValueToSize(value);
		}
		
		/**
		 */
		protected function axisValueToSize(value:Object):Number
		{
			var position:Number;
			
			if (confirmedSourceValueRange)
				position = getValuePercent(value) * this.fullSize - offsetSize;
			else
				position = 0;
			
			if (this.inverse)
				position = this.fullSize - position;

			return position;
		}
		
		/**
		 */		
		private var offsetSize:Number = 0;
		
		/**
		 */		
		private function getValuePercent(value:Object):Number
		{
			if (value == null)
				return 0;
			else
				return (Number(value) - this.sourceDataRange.min) / confirmedSourceValueRange;
		}

		/**
		 * @param value
		 * @return
		 */
		override public function valueToX(value:Object):Number
		{
			return axisValueToX(value);
		}

		/**
		 */
		override public function valueToY(value:Object):Number
		{
			return axisValueToY(value);
		}
		
		/**
		 */		
		override public function valueToZ(value:Object):Number
		{
			return this.getValuePercent(value);
		}

		/**
		 */
		override protected function get type():String
		{
			return AxisBase.LINER_AXIS;
		}

		/**
		 */
		protected var confirmedSourceValueRange:Number
			

		/**
		 */
		protected var _minimum:Number = 0;

		public function get minimum():Number
		{
			return _minimum;
		}

		public function set minimum(v:Number):void
		{
			assignedMinimum = v;
		}

		/**
		 */
		protected var _maximum:Number = 0;

		public function get maximum():Number
		{
			return _maximum;
		}

		public function set maximum(v:Number):void
		{
			assignedMaximum = v;
		}

		/**
		 */
		private var _baseAtZero:Boolean = true;

		public function get baseAtZero():Object
		{
			return _baseAtZero;
		}

		public function set baseAtZero(v:Object):void
		{
			_baseAtZero = XMLVOMapper.boolean(v);
		}
	}
}