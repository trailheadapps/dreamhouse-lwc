# Reset all local changes by reverting to git's latest commit
git reset --hard

# Redeploy clean metadata
sf project deploy start --ignore-conflicts