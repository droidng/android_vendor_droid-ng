/*
 * Copyright (C) 2012 The CyanogenMod Project
 *               2017-2019,2021 The LineageOS project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.eu.droid_ng.ngparts;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.ConnectivitySettingsManager;
import android.os.SystemProperties;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

public class BootReceiver extends BroadcastReceiver {

    private static final String TAG = "BootReceiver";

    private static final String[] allPkgNames = new String[] {
            "com.google.android.apps.restore", "com.google.android.tts", "com.google.android.feedback",
            "com.google.android.syncadapters.contacts", "com.google.android.gms", "com.android.vending",
            "com.google.android.partnersetup", "com.google.android.syncadapters.calendar",
            "com.google.android.googlequicksearchbox", "com.google.android.setupwizard",
            "com.google.android.projection.gearhead", "com.google.android.marvin.talkback"
    };

    private static final String[] restrictedPerms = new String[] {
            "android.permission.SEND_SMS", "android.permission.RECEIVE_SMS", "android.permission.READ_SMS",
            "android.permission.RECEIVE_WAP_PUSH", "android.permission.RECEIVE_MMS", "android.permission.READ_CELL_BROADCASTS",
            "android.permission.ACCESS_BACKGROUND_LOCATION", "android.permission.READ_CALL_LOG",
            "android.permission.WRITE_CALL_LOG", "android.permission.PROCESS_OUTGOING_CALLS"
    };

    private static final String[] restrictedPkgNames = new String[] {
            "com.google.android.gms", "com.android.vending", "com.google.android.googlequicksearchbox",
            "com.google.android.setupwizard", "com.google.android.projection.gearhead"
    };

    @Override
    public void onReceive(Context ctx, Intent intent) {
        Log.i("NgParts", "BootReciever: welcome to droid-ng!");
        /* gms feature */
        if (needWhitelist(ctx)) {
            Log.i("NgParts", "GmsFeature: setting up google features");
            addAllUids(ctx, getUidsForPkgNames(ctx));
            setupPermissions(ctx);
        } else {
            Log.i("NgParts", "GmsFeature: skipped setting up google features");
        }
    }

    @SuppressLint("NewApi")
    private static void setupPermissions(Context ctx) {
        PackageManager pm = ctx.getPackageManager();

        for (String pkg : restrictedPkgNames) {
            for (String perm : restrictedPerms) {
                try {
                    pm.addWhitelistedRestrictedPermission(pkg, perm, PackageManager.FLAG_PERMISSION_WHITELIST_SYSTEM);
                } catch (SecurityException | IllegalArgumentException | IllegalStateException e) {
                    e.printStackTrace();
                }
            }
        }

    }
    
    private static boolean needWhitelist(Context ctx) {
        PackageManager pm = ctx.getPackageManager();

        Set<Integer> uids =
                ConnectivitySettingsManager.getUidsAllowedOnRestrictedNetworks(
                        ctx);
        try {
            return !uids.contains(getUidForPkgName(pm, "com.google.android.gms"));
        } catch (PackageManager.NameNotFoundException e) {
            e.printStackTrace();
            return false;
        }
    }

    private static List<Integer> getUidsForPkgNames(Context ctx) {
        PackageManager pm = ctx.getPackageManager();
        ArrayList<Integer> u = new ArrayList<>();
        for (String pkgName : BootReceiver.allPkgNames) {
            try {
                u.add(getUidForPkgName(pm, pkgName));
            } catch (PackageManager.NameNotFoundException e) {
                e.printStackTrace();
            }
        }
        return u.stream().distinct().collect(Collectors.toList());
    }

    private static int getUidForPkgName(PackageManager pm, String pkgName) throws PackageManager.NameNotFoundException {
        return pm.getApplicationInfo(pkgName, 0).uid;
    }

    private static void addAllUids(Context ctx, List<Integer> uid) {
        Set<Integer> uids =
                ConnectivitySettingsManager.getUidsAllowedOnRestrictedNetworks(
                        ctx);
        uids.addAll(uid);
        ConnectivitySettingsManager.setUidsAllowedOnRestrictedNetworks(ctx,
                uids);
    }

}
