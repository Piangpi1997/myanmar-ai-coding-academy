"""Copy public learning content into runtime bundles, or check that they match.
No private grading oracles belong in this catalog.
"""
from pathlib import Path
import argparse
root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser()
parser.add_argument('--check', action='store_true')
args = parser.parse_args()
source = (root / 'content/learning_catalog.json').read_bytes()
for name in ['backend/app/data/learning_catalog.json', 'mobile/assets/learning/learning_catalog.json']:
    path = root / name
    if args.check:
        if not path.is_file() or path.read_bytes() != source:
            raise SystemExit('Catalog is out of sync: ' + name)
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_bytes(source)
print('Public learning catalog matches runtime bundles.' if args.check else 'Updated runtime catalog copies.')
