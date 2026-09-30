"""Build the small navigation-inset bridge. Requires JDK17, Android SDK and Godot Android template."""
import argparse, pathlib, subprocess, zipfile, tempfile
parser=argparse.ArgumentParser()
parser.add_argument('--jdk',required=True);parser.add_argument('--sdk',required=True)
a=parser.parse_args();root=pathlib.Path(__file__).resolve().parents[1]
work=root/'build/banner-safe';work.mkdir(parents=True,exist_ok=True)
with zipfile.ZipFile(root/'android/build/libs/debug/godot-lib.template_debug.aar') as z:(work/'godot.jar').write_bytes(z.read('classes.jar'))
classes=pathlib.Path(tempfile.mkdtemp(prefix='classes-',dir=work))
subprocess.run([str(pathlib.Path(a.jdk)/'bin/javac.exe'),'-source','17','-target','17','-classpath',str(work/'godot.jar')+';'+str(pathlib.Path(a.sdk)/'platforms/android-36/android.jar'),'-d',str(classes),*[str(p) for p in (root/'addons/banner_safe').glob('*.java')]],check=True)
with zipfile.ZipFile(work/'classes.jar','w') as z:
 for p in classes.rglob('*.class'):z.write(p,p.relative_to(classes).as_posix())
manifest='''<manifest xmlns:android="http://schemas.android.com/apk/res/android" package="com.cinderdominion.ads"><application><meta-data android:name="org.godotengine.plugin.v2.BannerSafe" android:value="com.cinderdominion.ads.BannerSafe" /></application></manifest>'''
with zipfile.ZipFile(root/'addons/banner_safe/banner-safe.aar','w',zipfile.ZIP_DEFLATED) as z:
 z.writestr('AndroidManifest.xml',manifest);z.write(work/'classes.jar','classes.jar')
print('Built banner-safe.aar')
