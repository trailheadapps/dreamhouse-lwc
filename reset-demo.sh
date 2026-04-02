echo "[1/3] Reset all local changes by reverting to git's latest commit"
git reset --hard
echo ""

echo "[2/3] Remove extra metadata"
sf project deploy start --manifest "reset-metadata/package.xml" --pre-destructive-changes "reset-metadata/destructiveChangesPre.xml" --purge-on-delete
echo ""

echo "[3/3] Redeploy clean metadata"
sf project deploy start --ignore-conflicts -d force-app
echo ""

echo "Done: demo is reset."
echo ""
