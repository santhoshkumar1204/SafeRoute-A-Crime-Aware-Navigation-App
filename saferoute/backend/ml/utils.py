from pathlib import Path


def get_dataset_paths(base_dir: Path) -> tuple[Path, Path]:
    train_path = base_dir / "crimedatasets" / "crime_train_full_merged.csv"
    test_path = base_dir / "crimedatasets" / "crime_test_full_merged.csv"
    return train_path, test_path

