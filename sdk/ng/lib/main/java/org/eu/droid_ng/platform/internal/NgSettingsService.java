/*
 * Copyright (C) 2018 The LineageOS Project
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

package org.eu.droid_ng.platform.internal;

import android.content.Context;

import org.eu.droid_ng.app.NgContextConstants;

/** @hide */
public class NgSettingsService extends NgSystemService {

    private static final String TAG = NgSettingsService.class.getSimpleName();

    private final Context mContext;

    public NgSettingsService(Context context) {
        super(context);
        mContext = context;
    }

    @Override
    public String getFeatureDeclaration() {
        return NgContextConstants.Features.SETTINGS;
    }

    @Override
    public void onBootPhase(int phase) {
    }

    @Override
    public void onStart() {
    }
}
