import UIKit

class DailyForecastCell: UITableViewCell {
    private let dayLabel = UILabel()
    private let iconImageView = UIImageView()
    private let highTempLabel = UILabel()
    private let lowTempLabel = UILabel()
    private let temperatureBar = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Clear default background and selection
        backgroundColor = .clear
        selectionStyle = .none
        
        // Configure day label
        dayLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        dayLabel.textColor = .white
        
        // Configure icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        
        // Configure temperature labels
        highTempLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        highTempLabel.textColor = .white
        highTempLabel.textAlignment = .right
        
        lowTempLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        lowTempLabel.textColor = .white.withAlphaComponent(0.7)
        lowTempLabel.textAlignment = .right
        
        // Configure temperature bar
        temperatureBar.backgroundColor = .clear
        
        // Add subviews
        contentView.addSubview(dayLabel)
        contentView.addSubview(iconImageView)
        contentView.addSubview(highTempLabel)
        contentView.addSubview(lowTempLabel)
        contentView.addSubview(temperatureBar)
        
        // Set up constraints
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        highTempLabel.translatesAutoresizingMaskIntoConstraints = false
        lowTempLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dayLabel.widthAnchor.constraint(equalToConstant: 100),
            
            iconImageView.leadingAnchor.constraint(equalTo: dayLabel.trailingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            lowTempLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            lowTempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            lowTempLabel.widthAnchor.constraint(equalToConstant: 40),
            
            highTempLabel.trailingAnchor.constraint(equalTo: lowTempLabel.leadingAnchor, constant: -16),
            highTempLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            highTempLabel.widthAnchor.constraint(equalToConstant: 40),
            
            temperatureBar.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            temperatureBar.trailingAnchor.constraint(equalTo: highTempLabel.leadingAnchor, constant: -16),
            temperatureBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            temperatureBar.heightAnchor.constraint(equalToConstant: 4)
        ])
    }
    
    func configure(day: String, high: String, low: String, icon: UIImage?) {
        dayLabel.text = day
        highTempLabel.text = high
        lowTempLabel.text = low
        iconImageView.image = icon
        
        // Create the temperature gradient bar
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: temperatureBar.bounds.width, height: 4)
        gradientLayer.cornerRadius = 2
        gradientLayer.colors = [
            UIColor.systemBlue.withAlphaComponent(0.7).cgColor,
            UIColor.systemYellow.withAlphaComponent(0.7).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        
        // Remove previous gradient layers
        temperatureBar.layer.sublayers?.forEach { if $0 is CAGradientLayer { $0.removeFromSuperlayer() } }
        temperatureBar.layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Update gradient frame when view is laid out
        temperatureBar.layer.sublayers?.forEach { 
            if let gradientLayer = $0 as? CAGradientLayer {
                gradientLayer.frame = CGRect(x: 0, y: 0, width: temperatureBar.bounds.width, height: 4)
            }
        }
    }
}