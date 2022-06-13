function __print_ng_functions_help() {
cat <<EOF
Additional droid-ng functions:
- ngremote:        Add git remote for droid-ng GitHub.
- ghfork:          Fork repo from Lineage, or if branch-repo combo doesn't exist, create one.
- eatwrp:          eat, but for TWRP.
- losfetch:        Fetch current repo from Lineage.
- aospfetch:       Fetch current repo from AOSP.
- losmerge:        Merge current repo with Lineage.
- push:            Push new commits to droid-ng github.
- pushall:         Push new commits from all repos to droid-ng github.
- mergeall:        Merge all repos with Lineage.
- pull:            Pull new commits from droid-ng github.
EOF
}

# active branch
if [ -z "$NG_BRANCH" ]; then
    NG_BRANCH=ng-v3
fi

# device branch
if [ -z "$DEV_BRANCH" ]; then
    DEV_BRANCH=ng-v3
fi

# lineage branch
if [ -z "$LOS_BRANCH" ]; then
    LOS_BRANCH=lineage-19.1
fi

# aosp tag
if [ -z "$AOSP_TAG" ]; then
    AOSP_TAG=$(python3 $ANDROID_BUILD_TOP/vendor/droid-ng/tools/get-aosp-tag.py)
fi

function ngremote()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    git remote rm ng 2> /dev/null
    local REMOTE=$(git config --get remote.github.projectname)
    local LINEAGE="true"
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.aosp.projectname)
        LINEAGE="false"
    fi
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.caf.projectname)
        LINEAGE="false"
    fi
    if [ -z "$REMOTE" ]
    then
	echo "Failed to find repo name."
	return 1
    fi

    if [ $LINEAGE = "false" ]
    then
        local PROJECT=$(echo $REMOTE | sed -e "s#platform/#android/#g; s#/#_#g")
    else
	local PROJECT=$(echo $REMOTE | sed -e "s#LineageOS/##g")
    fi
    local ORG=droidng
    local PFX="$ORG/"

    git remote add ng ssh://git@github.com/$PFX$PROJECT
    echo "Remote 'ng' created"
}

function ghfork()
{
    if ! git rev-parse --git-dir &> /dev/null
    then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi
    local REMOTE=$(git config --get remote.github.projectname)
    local LINEAGE="true"
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.aosp.projectname)
        LINEAGE="false"
    fi
    if [ -z "$REMOTE" ]
    then
	echo "Failed to find repo name."
	return 1
    fi
    git remote rm ng 2> /dev/null
    local ORG=droidng
    local PFX="$ORG/"
    if [ $LINEAGE = "false" ]
    then
        local PROJECT=$(echo $REMOTE | sed -e "s#platform/#android/#g; s#/#_#g")
	local REPO=$PFX$PROJECT
	gh repo create --public --disable-wiki --disable-issues $ORG/"$PROJECT"
    else
	local PROJECT=$(echo $REMOTE | sed -e "s#LineageOS/##g")
	local REPO=$PFX$PROJECT
	gh repo fork --org=$ORG --remote=false --clone=false LineageOS/"$PROJECT"
    fi
    git remote add ng ssh://git@github.com/"$REPO"
    git push ng HEAD:refs/heads/"$NG_BRANCH"
    gh repo edit "$REPO" --default-branch="$NG_BRANCH"
    cd "$ANDROID_BUILD_TOP/android"
    for branch in $(git ls-remote --heads ssh://git@github.com/"$REPO" | cut -f2); do 
	if [ "$branch" != "refs/heads/$NG_BRANCH" ]; then
            echo Deleting "$branch"
            git push --delete ssh://git@github.com/"$REPO" "$branch"
	fi
    done
    cd -

    echo -n "Repo '$REPO' created"
    if [ $LINEAGE = "true" ]
    then
        echo -n " (forked from 'LineageOS/$PROJECT')"
    fi
    echo ", pushed HEAD as '$NG_BRANCH', set it to default branch, created remote 'ng' and deleted all irrelevant branches from remote."
}

function eatwrp()
{
    if [ "$OUT" ] ; then
        ZIPPATH=`ls -tr "$OUT"/droid-ng-*.zip | tail -1`
        if [ ! -f $ZIPPATH ] ; then
            echo "Nothing to eat"
            return 1
        fi
        if [[ "$(adb get-state)" != sideload ]]
        then
        echo "Waiting for device..."
        adb wait-for-device-recovery
        echo "Found device"
        if ! (adb shell getprop ro.lineage.device | grep -q "$LINEAGE_BUILD"); then
            echo "The connected device does not appear to be $LINEAGE_BUILD, run away!"
	    return 1
        else
            echo "Please reboot to recovery and start sideload for install"
	fi
	fi
            adb wait-for-sideload
            adb sideload $ZIPPATH
	    adb wait-for-recovery
	    adb shell twrp reboot
        return $?
    else
        echo "Nothing to eat"
        return 1
    fi
}

function losfetch() {
    local REMOTE=$(git config --get remote.ng.projectname)
    if [ -z "$REMOTE" ]
    then
	echo "Is this an droid-ng repo?"
	return 1
    fi
    local REMOTE=$(git config --get remote.github.url)
    if [ -z "$REMOTE" ]
    then
        githubremote
    fi
    local REMOTE=$(git config --get remote.github.url)
    if ! git ls-remote --heads "$REMOTE" 2>/dev/null | cut -f2 | grep -q "$LOS_BRANCH"; then
        echo "LOS has no branch for this repo, fetching from AOSP"
	aospfetch
	return 0
    fi
    git fetch github "$LOS_BRANCH"
}

function aospfetch() {
    local REMOTE=$(git config --get remote.ng.projectname)
    if [ -z "$REMOTE" ]
    then
	echo "Is this an droid-ng repo?"
	return 1
    fi
    local REMOTE=$(git config --get remote.aosp.url)
    if [ -z "$REMOTE" ]
    then
        aospremote
    fi
    local REMOTE=$(git config --get remote.aosp.url)
    local AOSP_TAG=$(python3 $ANDROID_BUILD_TOP/vendor/droid-ng/tools/get-aosp-tag.py)
    git fetch aosp "$AOSP_TAG"
}

function losmerge() {
    losfetch || return 0
    git merge FETCH_HEAD || zsh
}

function push() {
    local REMOTE=$(git config --get remote.ng.projectname)
    local RH=ng
    local BRNCH=$NG_BRANCH
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.devices.projectname)
	RH=devices
	BRNCH=$DEV_BRANCH
    fi
    if [ -z "$REMOTE" ]
    then
	echo "Is this an droid-ng repo?"
	return 1
    fi
    git push "$RH" HEAD:"$BRNCH" $@
}

function pull() {
    local REMOTE=$(git config --get remote.ng.projectname)
    local RH=ng
    local BRNCH=$NG_BRANCH
    if [ -z "$REMOTE" ]
    then
        REMOTE=$(git config --get remote.devices.projectname)
	RH=devices
	BRNCH=$DEV_BRANCH
    fi
    if [ -z "$REMOTE" ]
    then
	echo "Is this an droid-ng repo?"
	return 1
    fi
    git pull "$RH" "$BRNCH" $@
}

function mergeall() {
    for i in $(repo forall -c pwd); do  # For every repo project..
        if [[ "$i" != "$ANDROID_BUILD_TOP/ng/"* ]] && # except ng/*...
	[[ "$i" != "$ANDROID_BUILD_TOP/packages/apps/MtkFMRadio" ]] &&  # and MtkFMRadio...
	[[ "$i" != "$ANDROID_BUILD_TOP/vendor/support" ]] &&  # and support...
	[[ "$i" != "$ANDROID_BUILD_TOP/packages/apps/FaceUnlockService" ]] &&  # and FaceUnlockService...
	[[ "$i" != "$ANDROID_BUILD_TOP/device/mediatek/sepolicy_vndr" ]] &&  # and sepolicy_vndr...
	[[ "$i" != "$ANDROID_BUILD_TOP/packages/resources/NgTranslations" ]] &&  # and NgTranslations...
	[[ "$i" != "$ANDROID_BUILD_TOP/external/zlib-ng" ]]; then  # and zlib-ng...
	# which are no forks..
	cd $i; pwd | cut -b ${#ANDROID_BUILD_TOP}- ; losmerge; cd - 1>/dev/null # merge from Lineage.
    fi; done
}

function pushall() {
    for i in $(repo forall -c pwd); do  # For every repo project..
	cd $i; pwd # cd
	push $@ # push
	cd - 1>/dev/null # cd back
    done
}
