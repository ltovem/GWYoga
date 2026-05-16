import UIKit
import GWYogaKit

/// Main navigation: UICollectionView with categorized demo entries — uses Yoga for layout.
@objc(CategoryListViewController)
open class CategoryListViewController: UIViewController {

    private var collectionView: UICollectionView!
    private var categories: [DemoCategory] = []

    open override func loadView() {
        let root = YogaLayoutView()
        root.backgroundColor = .systemBackground
        root.yoga.flexDirection = .column
        view = root
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        title = "GWYogaKit Demos"
        categories = DemoCategories.all

        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 16, bottom: 8, trailing: 16)

            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(36))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(DemoCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "header")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.yoga.flexGrow = 1

        guard let root = view as? YogaLayoutView else { return }
        root.addSubview(collectionView)
    }
}

// MARK: - UICollectionView DataSource / Delegate

extension CategoryListViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    public func numberOfSections(in collectionView: UICollectionView) -> Int { categories.count }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DemoCell
        let item = categories[indexPath.section].items[indexPath.row]
        cell.configure(with: item)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let h = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header", for: indexPath) as! SectionHeader
        h.label.text = categories[indexPath.section].name
        return h
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = categories[indexPath.section].items[indexPath.row]
        collectionView.deselectItem(at: indexPath, animated: true)

        if let vc = DemoRegistry.shared.viewController(for: item.route) {
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Coming Soon", message: "\(item.title) demo is coming.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
}

// MARK: - Demo Cell (GWYogaKit layout)

private class DemoCell: UICollectionViewCell {
    private let titleLabel = UILabel()
    private let descLabel = UILabel()
    private let arrow = UILabel()
    private let container = YogaLayoutView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        layer.cornerRadius = 10

        arrow.text = "›"
        arrow.font = .systemFont(ofSize: 24, weight: .light)
        arrow.textColor = .tertiaryLabel
        arrow.textAlignment = .center

        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        descLabel.font = .systemFont(ofSize: 12)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 2

        container.yoga.flexDirection = .row
        container.yoga.alignItems = .center
        container.yoga.flexGrow = 1

        let textStack = YogaLayoutView()
        textStack.yoga.flexDirection = .column
        textStack.yoga.flexGrow = 1
        textStack.addSubview(titleLabel)
        textStack.addSubview(descLabel)
        container.addSubview(textStack)
        container.addSubview(arrow)

        contentView.addSubview(container)
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.frame = contentView.bounds.insetBy(dx: 14, dy: 0)
        container.performYogaLayout()
    }

    func configure(with item: DemoItem) {
        titleLabel.text = item.title
        descLabel.text = item.desc
    }
}

// MARK: - Section Header (GWYogaKit layout)

private class SectionHeader: UICollectionReusableView {
    let label = UILabel()
    private let container = YogaLayoutView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .label
        container.style.marginLeft(16)
        container.addSubview(label)
        addSubview(container)
    }

    required init?(coder: NSCoder) { nil }

    override func layoutSubviews() {
        super.layoutSubviews()
        container.frame = bounds
        container.performYogaLayout()
    }
}
