import SwiftUI
import PDFKit

enum PDFExportError: Error, LocalizedError {
    case pageCreationFailed
    case documentWriteFailed
    case contentGenerationFailed
    
    var errorDescription: String? {
        switch self {
        case .pageCreationFailed:
            return "Failed to create PDF page"
        case .documentWriteFailed:
            return "Failed to save PDF document"
        case .contentGenerationFailed:
            return "Failed to generate PDF content"
        }
    }
}

class PracticeExporter {
    // Cache the logo image to avoid loading it repeatedly
    private static var cachedLogo: UIImage? = {
        if let logo = UIImage(named: "AppLogo") {
            // Pre-scale the logo to the size we want
            let size = CGSize(width: 150, height: 45) // Smaller size
            UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
            logo.draw(in: CGRect(origin: .zero, size: size))
            let scaledLogo = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return scaledLogo
        }
        return nil
    }()

    static func generatePDF(for practice: Practice) throws -> PDFDocument {
        // Move content generation outside of the PDF rendering context
        let (content, leftColumn, rightColumn) = try generateContent(for: practice)
        
        // Create the PDF document
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792)
        let format = UIGraphicsPDFRendererFormat()
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            context.beginPage()
            
            // Draw white background
            UIColor.white.set()
            context.fill(pageRect)
            
            // Draw header content
            let headerFrame = CGRect(x: 72, y: 72, width: 468, height: 100)
            content.draw(in: headerFrame)
            
            // Draw columns
            let columnY = headerFrame.maxY
            let leftFrame = CGRect(x: 72, y: columnY, width: 224, height: 500)
            let rightFrame = CGRect(x: 316, y: columnY, width: 224, height: 500)
            
            leftColumn.draw(in: leftFrame)
            rightColumn.draw(in: rightFrame)
            
            // Draw footer content
            let footerY = columnY + 300
            let (separatorContent, metricsContent) = generateFooterContent(for: practice)
            
            let separatorFrame = CGRect(x: 72, y: footerY, width: 468, height: 50)
            separatorContent.draw(in: separatorFrame)
            
            let metricsFrame = CGRect(x: 72, y: footerY + 40, width: 468, height: 100)
            metricsContent.draw(in: metricsFrame)
            
            // Draw logo
            if let logoImage = cachedLogo {
                let logoSize = CGSize(width: 150, height: 45) // Smaller size
                let logoX = (pageRect.width - logoSize.width) / 2
                let logoY = metricsFrame.maxY + 30 // Reduced spacing
                let logoRect = CGRect(x: logoX, y: logoY, width: logoSize.width, height: logoSize.height)
                logoImage.draw(in: logoRect, blendMode: .normal, alpha: 0.7)
            }
        }
        
        guard let pdfDocument = PDFDocument(data: data) else {
            throw PDFExportError.pageCreationFailed
        }
        return pdfDocument
    }
    
    private static func generateContent(for practice: Practice) throws -> (header: NSMutableAttributedString, left: NSMutableAttributedString, right: NSMutableAttributedString) {
        let content = NSMutableAttributedString()
        
        // Add title
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 24, weight: .bold),
            .foregroundColor: UIColor.black
        ]
        content.append(NSAttributedString(string: "\(practice.displayTitle)\n", attributes: titleAttributes))
        
        // Add date and time
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        let dateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.gray
        ]
        content.append(NSAttributedString(string: "\(dateFormatter.string(from: practice.date))\n", attributes: dateAttributes))
        
        // Add separator
        let separatorAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.gray
        ]
        content.append(NSAttributedString(string: "────────────────────────────────────────────\n", attributes: separatorAttributes))
        content.append(NSAttributedString(string: "────────────────────────────────────────────\n\n", attributes: separatorAttributes))
        
        // Split sections
        let sections = practice.sections.filter { $0 != practice.displayTitle }
        let midPoint = (sections.count + 1) / 2
        let leftSections = Array(sections[..<midPoint])
        let rightSections = Array(sections[midPoint...])
        
        // Create columns
        let leftColumn = NSMutableAttributedString()
        let rightColumn = NSMutableAttributedString()
        
        // Process sections
        for i in 0..<max(leftSections.count, rightSections.count) {
            if i < leftSections.count {
                appendSection(leftSections[i], to: leftColumn)
            }
            if i < rightSections.count {
                appendSection(rightSections[i], to: rightColumn)
            }
        }
        
        return (content, leftColumn, rightColumn)
    }
    
    private static func generateFooterContent(for practice: Practice) -> (separator: NSMutableAttributedString, metrics: NSMutableAttributedString) {
        let separatorAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.gray
        ]
        
        let separatorContent = NSMutableAttributedString()
        separatorContent.append(NSAttributedString(string: "────────────────────────────────────────────\n", attributes: separatorAttributes))
        separatorContent.append(NSAttributedString(string: "────────────────────────────────────────────\n", attributes: separatorAttributes))
        
        let metricsContent = NSMutableAttributedString()
        let detailsAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16),
            .foregroundColor: UIColor.black
        ]
        
        if practice.type != .rest {
            let intensityRating = Int(practice.intensity * 10)
            metricsContent.append(NSAttributedString(string: "Intensity: \(intensityRating)/10\n", attributes: detailsAttributes))
        }
        if practice.liveTimeMinutes > 0 {
            metricsContent.append(NSAttributedString(string: "Live Time: \(practice.liveTimeMinutes) minutes\n", attributes: detailsAttributes))
        }
        if practice.includesLift {
            metricsContent.append(NSAttributedString(string: "Includes Lift\n", attributes: detailsAttributes))
        }
        
        return (separatorContent, metricsContent)
    }
    
    private static func appendSection(_ section: String, to attributedString: NSMutableAttributedString) {
        if section.contains(": ") {
            // This is a block with a title
            let components = section.split(separator: ": ", maxSplits: 1).map(String.init)
            let blockTitle = components[0]
            let blockContent = components.count > 1 ? components[1] : ""
            
            // Add block title in bold
            let blockTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            attributedString.append(NSAttributedString(string: "\(blockTitle)\n", attributes: blockTitleAttributes))
            
            // Add block content with indent
            if !blockContent.isEmpty {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.firstLineHeadIndent = 20
                paragraphStyle.headIndent = 20
                
                let blockContentAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 14),
                    .foregroundColor: UIColor.black,
                    .paragraphStyle: paragraphStyle
                ]
                attributedString.append(NSAttributedString(string: "\(blockContent)\n", attributes: blockContentAttributes))
            }
        } else {
            // This is a section without a title
            let blockTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            attributedString.append(NSAttributedString(string: "\(section)\n", attributes: blockTitleAttributes))
        }
        
        // Add spacing after each section
        attributedString.append(NSAttributedString(string: "\n", attributes: [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.black
        ]))
    }
    
    static func savePDF(_ document: PDFDocument, for practice: Practice) throws -> URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "Practice-\(dateFormatter.string(from: practice.date)).pdf"
        
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Failed to get documents directory")
            throw PDFExportError.documentWriteFailed
        }
        
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        print("Saving PDF to: \(fileURL.path)")
        
        if document.write(to: fileURL) {
            print("PDF saved successfully")
            return fileURL
        } else {
            print("Failed to write PDF to file")
            throw PDFExportError.documentWriteFailed
        }
    }
} 
