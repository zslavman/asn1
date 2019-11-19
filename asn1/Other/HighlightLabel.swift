//
//  HighlightLabel.swift
//  Teamly
//
//  Created by Viacheslav on 15/11/19.
//  stackoverflow.com/questions/16362407/nsattributedstring-background-color-and-rounded-corners

import UIKit

class HighlightLabel: UITextView {
	
	private var highlightColor	: UIColor!
	private var atrStr			: NSAttributedString!

	
//	override init(frame: CGRect) {
//		super.init(frame: frame)
//
//	}
	convenience init(color: UIColor, atribute: NSAttributedString) {
		self.init(frame: .zero)
		self.highlightColor = color
		self.atrStr = atribute
	}
	
	override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func configWith(color: UIColor, atribute: NSAttributedString) {
		self.highlightColor = color
		self.atrStr = atribute
	}
	
	override func draw(_ rect: CGRect) {
		
		let frameSetter = CTFramesetterCreateWithAttributedString(atrStr as CFAttributedString)
		let path = CGMutablePath()
		path.addRect(CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height), transform: .identity)
		let totalFrame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, nil)
		// 6
		guard let context = UIGraphicsGetCurrentContext() else { return }
		context.textMatrix = .identity
		context.translateBy(x: 0, y: bounds.size.height)
		context.scaleBy(x: 1.0, y: -1.0)
		// 7
		let lines = CTFrameGetLines(totalFrame) as? [AnyHashable]
		let lineCount = CFIndex(lines?.count ?? 0)
		// 8
		var origins = [CGPoint](repeating: CGPoint.zero, count: lineCount)
		CTFrameGetLineOrigins(totalFrame, CFRangeMake(0, 0), &origins)
		
		for index in 0..<lineCount {
			//let line = CFArrayGetValueAtIndex(lines! as CFArray, index)
			let line: CTLine = unsafeBitCast(CFArrayGetValueAtIndex(lines! as CFArray, 0), to: CTLine.self)
			
			let glyphRuns = CTLineGetGlyphRuns(line)
			let glyphCount = CFArrayGetCount(glyphRuns)
			
			for i in 0..<glyphCount {
				//var run = CFArrayGetValueAtIndex(glyphRuns, i)
				let run: CTRun = unsafeBitCast(CFArrayGetValueAtIndex(glyphRuns, i), to: CTRun.self)
				
				let attributes = CTRunGetAttributes(run) as! [AnyHashable : Any]
				
				
				if let roundedBackingColor = attributes["MyRoundedBackgroundColor"] as? UIColor {
				//if attributes["HighlightText"] != nil {
					var runBounds: CGRect = .zero
					var ascent: CGFloat = 0
					var descent: CGFloat = 0
					
					runBounds.size.width = CGFloat(CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, nil))
					runBounds.size.height = ascent + descent
					// 13
					runBounds.origin.x = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, nil)
					//runBounds.origin.y = frame.size.height - origins[(lineCount - 1) - CFIndex(index)].y - runBounds.size.height
					runBounds.origin.y = frame.size.height - origins[(lineCount - 1) - index].y - runBounds.size.height
					
					
					
					let highlightCol = roundedBackingColor.cgColor
					
					// UIBezierPath way
					let clipPath: CGPath = UIBezierPath(roundedRect: runBounds, cornerRadius: 12).cgPath
					context.addPath(clipPath)
					context.setFillColor(highlightCol)
					context.closePath()
					context.fillPath()
					
					// CoreGraphis way
//					context.setFillColor(highlightCol)
//					context.setStrokeColor(highlightCol)
//					context.strokePath()
//					context.fill(runBounds)
				}
			}
		}
		//context.restoreGState()
		CTFrameDraw(totalFrame, context)
	}
	
	

	
	
}
