import UIKit

class HourlyForecastCell: UICollectionViewCell {
    private let timeLabel = UILabel()
    private let iconImageView = UIImageView()
    private let temperatureLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // Configure time label
        timeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        timeLabel.textColor = .white
        timeLabel.textAlignment = .center
        
        // Configure icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = .white
        
        // Configure temperature label
        temperatureLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        temperatureLabel.textColor = .white
        temperatureLabel.textAlignment = .center
        
        // Add subviews
        addSubview(timeLabel)
        addSubview(iconImageView)
        addSubview(temperatureLabel)
        
        // Set up constraints
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            iconImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 30),
            iconImageView.heightAnchor.constraint(equalToConstant: 30),
            
            temperatureLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 8),
            temperatureLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            temperatureLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            temperatureLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -8)
        ])
    }
    
    func configure(time: String, temperature: String, icon: UIImage?) {
        timeLabel.text = time
        temperatureLabel.text = temperature
        iconImageView.image = icon
    }
}