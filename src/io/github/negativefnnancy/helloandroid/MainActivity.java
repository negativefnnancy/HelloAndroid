package io.github.negativefnnancy.helloandroid;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;
import android.widget.Button;
import android.util.Log;

public class MainActivity extends Activity {
    public static final String TAG = "HelloAndroid";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Log.i(TAG, "The HelloAndroid app has started!:3");

        final Button button = (Button) findViewById(R.id.hello_button);
        final TextView textView = (TextView) findViewById(R.id.hello_text_view);

        button.setOnClickListener(new View.OnClickListener() {
            public void onClick(View view) {
                Log.i(TAG, "The silly button was pressed!!0_0");
                textView.setText(R.string.hello_text);
            }
        });
    }
}
