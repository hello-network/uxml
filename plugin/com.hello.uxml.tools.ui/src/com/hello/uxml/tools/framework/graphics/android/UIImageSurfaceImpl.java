package com.hello.uxml.tools.framework.graphics.android;
import com.hello.uxml.tools.framework.Size;
import com.hello.uxml.tools.framework.graphics.UIImageSurface;
import com.hello.uxml.tools.framework.platform.AndroidApplication;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

import java.io.IOException;
import java.io.InputStream;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

/**
 * Provides surface for rendering image.
 *
 * @author ferhat
 */
public class UIImageSurfaceImpl extends UISurfaceImpl implements UIImageSurface {

  private Object imageSource = "";
  private Bitmap deviceImage;

  /**
   * Sets image source.
   */
  @Override
  public void setSource(Object source) {
    if (this.imageSource != source) {
      if (deviceImage != null) {
        deviceImage.recycle();
        deviceImage = null;
      }
      this.imageSource = source;
      if (imageSource instanceof String) {
        String imageUrl = (String) imageSource;
        if ((imageUrl != null) && (!imageUrl.equals(""))) {
          if (imageUrl.toLowerCase().startsWith("embed:")) {
            String embeddedSource = imageUrl.substring(6);
            Context context = ((AndroidApplication) AndroidApplication.getCurrent()).getContext();
            int resourceId;
            if (embeddedSource.toLowerCase().startsWith("0x")) {
              resourceId = Integer.parseInt(embeddedSource.substring(2), 16);
            } else {
              resourceId = Integer.parseInt(embeddedSource);
            }
            deviceImage = BitmapFactory.decodeResource(context.getResources(), resourceId);
          } else {

            // load image from url
            try {
              deviceImage = loadImage(imageUrl);
            } catch (IOException e) {
              // TODO(ferhat) display error.
            }
          }
          if (deviceImage != null) {
            if (uiTarget != null) {
              uiTarget.surfaceContentUpdated();
            }
          }
        }
      }
    }
  }

  private Bitmap loadImage(String url) throws IOException {
    URL myFileUrl = null;
    Bitmap bitmapImage = null;
    try {
         myFileUrl = new URL(url);
    } catch (MalformedURLException e) {
         return null;
    }
    try {
         HttpURLConnection conn = (HttpURLConnection) myFileUrl.openConnection();
         conn.setDoInput(true);
         conn.connect();
         InputStream is = conn.getInputStream();
         bitmapImage = BitmapFactory.decodeStream(is);
    } catch (IOException e) {
         throw e;
    }
    return bitmapImage;
  }

  /**
   * Renders contents and children.
   */
  @Override
  public void paintControl(RenderContext context) {
    if (!visible) {
      return;
    }
    if (renderList != null) {
      super.paintControl(context);
    }
    if (deviceImage != null) {
      context.drawImage(deviceImage, 0, 0);
    }
  }

  /**
   * Measures size of image given width constraint.
   */
  @Override
  public Size measure() {
    if (deviceImage == null) {
      return new Size(0, 0);
    } else {
      return new Size(deviceImage.getWidth(), deviceImage.getHeight());
    }
  }

  /**
   * @see UISurfaceImpl
   */
  @Override
  public void setHitTestMode(int mode) {
    // Nothing to do here
  }
}
