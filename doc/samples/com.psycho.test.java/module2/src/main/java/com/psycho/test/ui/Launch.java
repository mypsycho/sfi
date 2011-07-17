package com.psycho.test.ui;

import java.awt.BorderLayout;
import java.awt.Container;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;

import com.psycho.test.service.Module1;



public class Launch {
    
    
    
    JFrame f;
    Module1 m;
    
    public Launch(Module1 model) {
        m = model;
    }
    
    public synchronized void start() {
        if (f != null) {
            return;
        }
        
        f = new JFrame();
        Container c = f.getContentPane();
        c.setLayout(new BorderLayout());
        c.add(new JLabel(m.execute2(), JLabel.CENTER), BorderLayout.CENTER);
        
        JButton b = new JButton("execute");
        b.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                m.execute1();
            }
        });
        c.add(b, BorderLayout.PAGE_END);
        
        f.addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                stop();
            }
        });
        f.setDefaultCloseOperation(JFrame.DO_NOTHING_ON_CLOSE);
        f.pack();
        f.setLocation(200, 200);
        f.setVisible(true);
    }
    
    public synchronized void stop() {
        f.dispose();
        f = null;
    }
    
    public static void main(String... arg) {
        Logging.init();
        
        new Launch(new Module1()).start();
    }

}