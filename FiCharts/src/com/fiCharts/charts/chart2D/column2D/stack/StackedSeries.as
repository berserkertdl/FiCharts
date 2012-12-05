package com.fiCharts.charts.chart2D.column2D.stack
{
	import com.fiCharts.charts.chart2D.core.axis.AxisBase;
	import com.fiCharts.charts.chart2D.encry.SeriesBase;
	import com.fiCharts.charts.common.SeriesDataItemVO;
	
	/**
	 * 
	 * @author wallen
	 * 
	 */	
	public class StackedSeries extends SeriesBase
	{
		public function StackedSeries()
		{
			super();
		}
		
		/**
		 * 不添加数据缩放事件监听， 所有处理都在主堆积序列中完成， 这里仅处理数据的初始化
		 */
		override public function set horizontalAxis(v:AxisBase):void
		{
			_horizontalAxis = v;
			_horizontalAxis.direction = AxisBase.HORIZONTAL_AXIS;
			_horizontalAxis.metaData = this;
		}
		
		/**
		 */		
		override public function beforeUpdateProperties(xml:*=null):void
		{
			
		}
		
		/**
		 */		
		override protected function get seriesDataItem():SeriesDataItemVO
		{
			return new StackedSeriesDataItem();
		}	
		
	}
}